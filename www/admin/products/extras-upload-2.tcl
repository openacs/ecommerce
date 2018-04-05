#  www/[ec_url_concat [ec_url] /admin]/products/extras-upload-2.tcl
ad_page_contract {
  This file updates ec_custom_product_field_values (as opposed to inserting
  new rows) because custom-field-add*.tcl (which are to be run before extras-upload*.tcl)
  insert rows into ec_custom_product_field_values (with everything empty except
  product_id and the audit columns) when they insert the rows into ec_products
  (for consistency with add*.tcl).

  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  csv_file
  csv_file.tmpfile:tmpfile
  file_type
  delimiter
}
set serious_errors 0
ad_require_permission [ad_conn package_id] admin

if { [empty_string_p $csv_file] } {
    ad_return_error "Missing Data File" "You must input the name of the file on your local hard drive."
    set serious_errors 1
}

set user_id [ad_get_user_id]
set ip [ns_conn peeraddr]

set title "Uploading Extras"
set context [list [list index Products] $title]

set unix_file_name ${csv_file.tmpfile}
# Check that the file is readible
if { ![file readable $unix_file_name] } {
    append doc_body "Cannot read file $unix_file_name"
    set serious_errors 1
}
# Check that delimiter is one character, if used
if { [string length $delimiter] != 1 && [string eq $file_type "delim"]} {
    append doc_body "Delimiter is not one character long."
    set serious_errors 1
}

set doc_body ""
set datafilefp [open $unix_file_name]
set count 0
set rows_updated 0
set rows_inserted 0
set errors 0
# Continue reading the file till the end but stop when an error
# occurred.

# read line, depending  on file type
if {[string eq $file_type "csv"]} {
    set line_status [ns_getcsv $datafilefp elements]
} elseif {[string eq $file_type "tab"]} {
    set line_status [ec_gets_char_delimited_line $datafilefp elements]
} elseif {[string eq $file_type "delim"]} {
    set line_status [ec_gets_char_delimited_line $datafilefp elements $delimiter]
} else {
    # no valid filetype chosen
    set line_status -1
}

while { $line_status != -1 && !$errors} {
    incr count
    if { $count == 1 } {
        # first time thru, we grab the number of columns and their names
        set number_of_columns [llength $elements]
        set columns $elements
        set product_id_column [lsearch -exact $columns "product_id"]
        # Caroline@meekshome.com Allows you to specify either the product_id or the sku
        set sku_column [lsearch -exact $columns "sku"]
        ns_log Notice "ecommerce extras-upload-2.tcl: beginning bulk uploading of custom product fields with file $csv_file"
    } else {
        # this line is a product
        # (this file used to insert rows into ec_custom_product_field_values, but
        # now that is done in upload-2.tcl, so we need to update instead)

        set sqlupdate "update ec_custom_product_field_values set last_modified=sysdate, last_modifying_user=:user_id, modified_ip_address=:ip"
        set sqlinsert_columns "insert into ec_custom_product_field_values (last_modified, last_modifying_user, modified_ip_address, product_id"
        set sqlinsert_values "values (sysdate, :user_id, :ip, :product_id"
        set moresqlupdate ""
        set moresqlinsert_columns ""
        set moresqlinsert_values ""
        # setup sql for custom field values
        for { set i 0 } { $i < $number_of_columns } { incr i } {
            set var_name "var_$i"
            set $var_name [lindex $elements $i]
            set field_name [lindex $columns $i]
            if { $i != ${product_id_column} && $i != ${sku_column} } {
                append moresqlupdate ", ${field_name}=:$var_name"
                append moresqlinsert_columns ", $field_name"
                append moresqlinsert_values ", :$var_name"
            }
        }
        # find the product and update the custom fields
        set length_sku 0
        set product_id 0
        # Caroline@meekshome.com - see if we have a product_id or need to use the sku
        if { $product_id_column > -1 } {
            set product_id var_${product_id_column}             
        } elseif { ${sku_column} > -1 && ${product_id} == 0 } {
            set sku_var var_${sku_column}
            set sku [expr $$sku_var]
            # sku supplied, product_id not supplied
            # still need to test for product_id below because sku might not have a product_id
            set product_id [db_string get_product_id_from_sku "select product_id from ec_products where sku = :sku" -default "0"]
            set length_sku [string length $sku]
        } 
        if { $product_id > 0 } {
            # check to see if data exists, or if this will be a new row
            set custom_product_id [db_string get_custom_field_product_id "select product_id as custom_product_id from ec_custom_product_field_values where product_id = :product_id" -default "0"]            
            if { $custom_product_id > 0} {
                set sql "${sqlupdate} ${moresqlupdate} where product_id=:product_id"
                if { [catch {db_dml product_update_with_product_id $sql} errmsg] } {
                    append bad_products_sql "$sql\n<"
                    append doc_body "</p><pre><font color=red>FAILURE!</font> SQL: $sql<br> $errmsg\n</pre><p>"
                } else {
                    append doc_body ". "
                    incr rows_updated
                }
            } else {
                # no custom fields exist for this product_id, insert custom fields
                set sql "${sqlinsert_columns} ${moresqlinsert_columns} ) ${sqlinsert_values} ${moresqlinsert_values} )"
                if { [catch {db_dml insert_custom_fields_with_product_id $sql} errmsg] } {
                    append bad_products_sql "$sql\n<"
                    append doc_body "</p><pre><font color=red>FAILURE!</font> SQL: $sql<br> $errmsg\n</pre><p>"
                } else {
                    append doc_body "i "
                    incr rows_inserted
                }
            }
            ecds_file_cache_product $product_id
        }  else {
            # adding ns_log for cases where uploading extends past max input time (config.tcl:recwait)
            ns_log Notice "While bulk uploading custom fields, cannot obtain an existing product_id for row $count in file $csv_file."
            append doc_body "</p><p>Row $count must supply either product_id ($product_id_column) or the sku ($sku_column); sku length: $length_sku number_of_columns: $number_of_columns,<br><pre>  row values: $elements</pre><p>"
        }
    }

    # read next line of data file, depending on file type, or end read loop if error.
    if {[string eq $file_type "csv"]} {
        set line_status [ns_getcsv $datafilefp elements]
    } elseif {[string eq $file_type "tab"]} {
        set line_status [ec_gets_char_delimited_line $datafilefp elements]
    } elseif {[string eq $file_type "delim"]} {
        set line_status [ec_gets_char_delimited_line $datafilefp elements $delimiter]
    } else {
        # no valid filetype chosen
        set line_status -1
    }

}
# post upload report to log in case the connection timed out.
ns_log Notice "Custom field bulk uploading has read $count lines from ${csv_file}. Updated $rows_updated rows. Inserted $rows_inserted rows."
append doc_body "</p>"
set count_html "[ec_decode $count "0" "0" [expr $count -1]]"


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

ad_require_permission [ad_conn package_id] admin

if { [empty_string_p $csv_file] } {
    ad_return_error "Missing Data File" "You must input the name of the file on your local hard drive."
    return
}

set user_id [ad_get_user_id]
set ip [ns_conn peeraddr]

doc_body_append "[ad_admin_header "Uploading Extras"]

<h2>Uploading Extras</h2>

[ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] "Uploading Extras"]

<hr>

"

set unix_file_name ${csv_file.tmpfile}

# Check that the file is readible
if { ![file readable $unix_file_name] } {
    doc_body_append "Cannot read file $unix_file_name"
    return
}
# Check that delimiter is one character, if used
if { [string length $delimiter] != 1 && [string eq $file_type "delim"]} {
    doc_body_append "Delimiter is not one character long."
    return
}

doc_body_append "<pre>
"

set datafilefp [open $unix_file_name]
set count 0
set errors 0
# Continue reading the file till the end but stop when an error
# occured.

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
    } else {
	# this line is a product
# (this file used to insert rows into ec_custom_product_field_values, but
# now that is done in upload-2.tcl, so we need to update instead)
# 	set columns_sql "insert into ec_custom_product_field_values (last_modified, last_modifying_user, modified_ip_address "
# 	set values_sql " values (sysdate or now(), $user_id, '$ip' "
# 	for { set i 0 } { $i < $number_of_columns } { incr i } {
# 	    append columns_sql ", [lindex $columns $i]"
# 	    append values_sql ", '[DoubleApos [lindex $elements $i]]'"
# 	}
# 	set sql "$columns_sql ) $values_sql )"

	set sql "update ec_custom_product_field_values set last_modified=sysdate, last_modifying_user=:user_id, modified_ip_address=:ip"
        set moresql ""

        for { set i 0 } { $i < $number_of_columns } { incr i } {
	    set var_name "var_$i"
	    set $var_name [lindex $elements $i]
	    if { $i != $product_id_column && $i != $sku_column} {
	        append moresql ", [lindex $columns $i]=:$var_name"
	    }
	}
        # Caroline@meekshome.com - see if we have a product_id or need to use the sku
        if { $product_id_column > -1 } {
            # product_id supplied
            append sql "${moresql} where product_id=:var_$product_id_column"
            if { [catch {db_dml product_update_with_product_id $sql} errmsg] } {
	        append bad_products_sql "$sql\n"
	        doc_body_append "<font color=red>FAILURE!</font> SQL: $sql<br> $errmsg\n"
	    } else {
	        doc_body_append "Success!<br>\n"
	    }
        } elseif { $sku_column > -1 } {
            append sql "${moresql} where product_id = (select product_id from ec_products where sku = :var_$sku_column)"
	    if { [catch {db_dml product_update_with_sku $sql} errmsg] } {
	        append bad_products_sql "$sql\n"
	        doc_body_append "<font color=red>FAILURE!</font> SQL: $sql<br> $errmsg\n"
	    } else {
	        doc_body_append "Success!<br>\n"
	    }
        } else {
            ad_return_complaint 1 "Each row must either supply the product_id ($product_id_column) or the sku ($sku_column); number_of_columns: $number_of_columns, columns: $columns"
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

doc_body_append "</pre>
<p>Done loading [ec_decode $count "0" "0" [expr $count -1]] products extras!

<p>

(Note: \"success\" doesn't actually mean that the information was uploaded; it
just means that the database did not choke on it (since updates to tables are considered
successes even if 0 rows are updated).  If you need reassurance, spot check some of the individual products.)
[ad_admin_footer]
"


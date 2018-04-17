#  www/[ec_url_concat [ec_url] /admin]/products/upload-2.tcl
ad_page_contract {

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

# We need them to be logged in

ad_require_permission [ad_conn package_id] admin
set user_id [ad_get_user_id]
set peeraddr [ns_conn peeraddr]

# Grab package_id as context_id
set context_id [ad_conn package_id]

set serious_errors 0

set title "Uploading Products"
set context [list [list index Products] $title]

# Get the name of the transferred data file
set unix_file_name ${csv_file.tmpfile}

# Check that the file is readable.
if { ![file readable $unix_file_name] } {
    append error_message "Cannot read file ${unix_file_name}. "
    set serious_errors 1
}
# Check that delimiter is one character, if used
if { [string length $delimiter] != 1 && [string eq $file_type "delim"]} {
    append error_message "Delimiter is not one character long."
    set serious_errors 1
}

# Accept only field names that exist in the ec_product table and are
# not set automatically like creation_date.

set legal_field_names {sku product_name one_line_description detailed_description search_keywords price no_shipping_avail_p \
                           shipping shipping_additional weight present_p active_p url template_id stock_status color_list \ 
                               size_list style_list email_on_purchase_list image_fullpathname}

# Check each entry in the datafile for the following required fields.
# These fields are required so that we can check if a product already
# in the products table and should be update rather than created.
set required_field_names {sku product_name}

# Initialize each legal field name as the datafile might not mention
# each and every one of them.
foreach legal_field_name $legal_field_names {
    set $legal_field_name ""
}

# Start reading.
# use file_type to determine which proc to delimit data
set datafilefp [open $unix_file_name]
set count 0
set errors $serious_errors
set success_count 0
set doc_body ""

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

# Continue reading the file till the end but stop when an error occurred.
while { $line_status != -1 && !$errors} {
    incr count
    if { $count == 1 } {

        # First row, grab the field names and their number.
        set field_names $elements
        set number_of_fields [llength $elements]

        # Check the field names against the list of legal names
        foreach field_name $field_names {
            if {[lsearch -exact $legal_field_names $field_name] == -1} {
                incr errors
                append doc_body "<p><font color=red>FAILURE!</font> $field_name is not an allowed field name.</p>"
            }
        }
    } else {

        # Subsequent rows, thus a product

        # Reset the required fields to NULL so that we can later check
        # if the data file gave them a value.

        foreach required_field_name $required_field_names {
            set $required_field_name ""
        }

        # Assign the values in the CSV to the field names.

        for { set i 0 } { $i < $number_of_fields } { incr i } {
            set [lindex $field_names $i] [lindex $elements $i]
        }

        # Check if all the required fields have been given a value

        foreach required_field_name $required_field_names {
            if {[set $required_field_name] == ""  && $required_field_name ne "product_name" } {
                incr errors
                ns_log Notice "ecommerce/www/admin/products/upload-2.tcl: a required fieldname is blank: $required_field_name"
            }
        }

        # be certain that present_p defaults to 't' if no value given
        # if it's not false it must be true

        if {[string equal $present_p "f"] != 1} {
            set present_p "t"
        }

        # be certain that no_shipping_avail_p defaults to 'f' if no value given
        # if it's not true it must be false

        if {[string equal no_shipping_avail_p "t"] != 1} {
            set no_shipping_avail_p "f"
        }

        # Create or update the product if all the required fields were
        # given values.

        if {!$errors} {

            # Check if there is already product with the give sku.
            # Set product_id to NULL so that ACS picks a unique id if
            # there no product with the gicen sku.

            set product_id [db_string product_check {select product_id from ec_products where sku = :sku;} -default ""]
            if { $product_id != ""} {
                if { $product_name eq "" } {
                    # use existing product_name
                    ns_log Notice "ecommerce/www/admin/products/upload-2.tcl: working on sku $sku"
                    db_1row get_product_name_from_product_id "select product_name from ec_products where product_id = :product_id"
                }


                # We found a product_id for the given sku, let's
                # update the product.
                if { [catch {db_dml product_update "
                    update ec_products set
                    user_id = :user_id,
                    product_name = :product_name,
                    price = :price,
                    one_line_description = :one_line_description,
                    detailed_description = :detailed_description,
                    search_keywords = :search_keywords,
                    present_p = :present_p,
                    stock_status = :stock_status,
                    now(),
                    color_list = :color_list,
                    size_list = :size_list,
                    style_list = :style_list,
                    email_on_purchase_list = :email_on_purchase_list,
                    url = :url,
                    no_shipping_avail_p = :no_shipping_avail_p,
                    shipping = :shipping,
                    shipping_additional = :shipping_additional,
                    weight = :weight,
                    active_p = 't',
                    template_id = :template_id
                    where product_id = :product_id;
                "} errmsg] } {
                    append doc_body "<p><font color=red>FAILURE!</font> Product update of <i>$product_name</i> failed with error:<\p><p>$errmsg</p>"
                } else {
                    append doc_body "<p>Updated $product_name</p>"
                    ecds_file_cache_product $product_id
                }
            } else {

                # Generate a product_id
                set product_id [db_nextval acs_object_id_seq]

                # Dirname will be the first four letters (lowercase)
                # of the product_name followed by the product_id (for
                # uniqueness)
                regsub -all {[^a-zA-Z]} $product_name "" letters_in_product_name 
                set letters_in_product_name [string tolower $letters_in_product_name]
                if [catch {set dirname "[string range $letters_in_product_name 0 3]$product_id"}] {
                    #maybe there aren't 4 letters in the product name
                    set dirname "${letters_in_product_name}$product_id"
                }

                # Get the directory where dirname is stored
                set subdirectory "[ec_data_directory][ec_product_directory][ec_product_file_directory $product_id]"
                ec_assert_directory $subdirectory

                set full_dirname "$subdirectory/$dirname"
                ec_assert_directory $full_dirname

                # There is no product with sku :sku so create a new
                # product.
                db_transaction {

                    if { [catch {db_exec_plsql product_insert "
                        select ec_product__new(
                        :product_id,
                        :user_id,
                        :context_id,
                        :product_name,
                        :price,
                        :sku,
                        :one_line_description,
                        :detailed_description,
                        :search_keywords,
                        :present_p,
                        :stock_status,
                        :dirname,
                        now(),
                        :color_list,
                        :size_list,
                        :peeraddr
                    )"} errmsg] } {
                        append doc_body "<font color=red>FAILURE!</font> Product creation of <i>$product_name</i> failed with error:<\p><p>$errmsg</p>"
                    } else {
                        append doc_body "<p>Created $product_name</p>"
                        ecds_file_cache_product $product_id
                        # we have to also write a row into ec_custom_product_field_values
                        # for consistency with add*.tcl (added 1999-08-08, inadvertently removed 20020504)
                        if { [catch {db_dml custom_product_field_insert "insert into ec_custom_product_field_values (product_id, last_modified, last_modifying_user, modified_ip_address) values (:product_id, now(), :user_id, :peeraddr)" } errmsg] } {
                        append doc_body "<font color=red>FAILURE!</font> Insert into ec_custom_product_field_values failed for product_id=$product_id with error: $errmsg<br>\n"
                        }
                    }
                }

                if { [catch {db_dml product_insert_2 "
                    update ec_products set 
                    style_list = :style_list,
                    email_on_purchase_list = :email_on_purchase_list,
                    url = :url,
                    no_shipping_avail_p = :no_shipping_avail_p,
                    shipping = :shipping,
                    shipping_additional = :shipping_additional,
                    weight = :weight,
                    active_p = 't',
                    template_id = :template_id
                    where product_id = :product_id;
                "} errmsg] } {
                    append doc_body "<font color=red>FAILURE!</font> Product update of new product <i>$product_name</i> failed with error:<\p><p>$errmsg</p>"
                }
            }
            # Product line is completed, increase counter
            incr success_count

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
set count [expr { $count -1 } ]
if { $success_count == 1 } {
    set product_string "product"
} else {
    set product_string "products"
}

set total_lines "[ec_decode $count "0" "0" [expr $count -1]]"

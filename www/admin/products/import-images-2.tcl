#  www/[ec_url_concat [ec_url] /admin]/products/import-images-2.tcl
ad_page_contract {

  @author Torben Brosten
  @creation-date 20-02-2005
  @cvs-id $Id$
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

doc_body_append "[ad_admin_header "Uploading Products"]

<h2>Bulk Import Product Images</h2>

[ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] "Bulk Import Product Images"]

<hr>

"

# Get the name of the transfered data file

set unix_file_name ${csv_file.tmpfile}

# Check that the file is readable.

if { ![file readable $unix_file_name] } {
    doc_body_append "Cannot read file $unix_file_name"
    return
}
# Check that delimiter is one character, if used
if { [string length $delimiter] != 1 && [string eq $file_type "delim"]} {
    doc_body_append "Delimiter is not one character long."
    return
}

# Accept (ignore) all field names, require sku and image_fullpathname

# Check each entry in the datafile for the following required fields.
# These fields are required so that we can check if a product already
# in the products table and should be update rather than created.

set required_field_names {sku image_fullpathname}
set number_of_req_fields [llength $required_field_names]
# Start reading.
# use file_type to determine which proc to delimit data

set datafilefp [open $unix_file_name]

set count 0
set errors 0
set success_count 0

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

        # First row, grab the field names and their number.

        set field_names $elements
        set number_of_fields [llength $elements]

    } else {

        # Subsequent rows, thus related to an existing product

        # Reset the required fields to NULL so that we can later check
        # if the data file gave them a value.

        set req_field_positions [list ""]
        set ii 0
        foreach required_field_name $required_field_names {
            set $required_field_name ""
            # set the column position for each required field
            set ${required_field_name}_column [lsearch -exact $field_names $required_field_name] 
        }

        # Assign the values in the datafile row to the required field names.

        foreach required_field_name $required_field_names {
            set $required_field_name [lindex $elements [lsearch -exact $field_names $required_field_name]]
            if { [empty_string_p $required_field_name] } {
                incr errors
            }
        }

        # copy the product image and create the thumbnail if all the required fields were
        # given values.

        if {!$errors} {

            # Check if there is a product with the give sku.
            # otherwise, there is no place to copy the product image to.
            set product_id [db_string product_check {select product_id from ec_products where sku = :sku} -default ""]
            if { $product_id != ""} {
                # We found a product_id for the given sku
                # get the product directory

                # copy image & create thumbnails
                # thumbnails are all jpg files

                if { [catch {ecommerce::resource::make_product_images \
                                 -file_extension [file extension $image_fullpathname] \
                                 -product_id $product_id \
                                 -tmp_filename $image_fullpathname} errmsg ] } {

                    doc_body_append "<p><font color=red>Error!</font>Image update of <i>$sku</i> failed with error:<\p><p>$errmsg</p>"
                } else {
                    doc_body_append "<p>Imported images for product: $sku</p>"
                    # A product row has been successfully processed, increase counter
                    incr success_count
                }

            } else {

                # Let them know this sku is not in the catalog
                doc_body_append "<font color=red>FAILURE!</font>Could not import image for sku: <i>$sku</i>, because sku was not found in catalog.</p>"
            }
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

if { $success_count == 1 } {
    set product_string "product image and thumbnail"
} else {
    set product_string "product images and thumbnails"
}

doc_body_append "<p>Successfully imported $success_count $product_string out of [ec_decode $count "0" "0" [expr $count -1]].

[ad_admin_footer]
"

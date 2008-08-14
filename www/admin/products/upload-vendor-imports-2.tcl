#  www/[ec_url_concat [ec_url] /admin]/products/upload-vendor-imports-2.tcl
ad_page_contract {

  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  csv_file
  csv_file.tmpfile:tmpfile
  abbrev
}

# We need them to be logged in

ad_require_permission [ad_conn package_id] admin
set user_id [ad_get_user_id]
set peeraddr [ns_conn peeraddr]

# Grab package_id as context_id

set context_id [ad_conn package_id]
set title "Import Vendors Products"
doc_body_append "[ad_admin_header $title]
<h2>$title</h2>

[ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] $title]
<hr>
<blockquote>
"

# Get the name of the transfered data file

set unix_file_name ${csv_file.tmpfile}

# Check that the file is readable.

if { ![file readable $unix_file_name] } {
    doc_body_append "Cannot read file $unix_file_name"
    return
}
# Check that vendor abbrev length is > 0
if { [string length $abbrev] == 0 } {
    doc_body_append "Vendor abbreviation does not exist."
    return
}

# Start reading.
# use file_type to determine which proc to delimit data

set datafilefp [open $unix_file_name]
set count 0
set errors 0
set success_count 0

# Continue reading the file till the end but stop when an error
# occured.


set line_status [ns_getcsv $datafilefp elements]
while { $line_status != -1 && !$errors } {


    # Create or update the product if all the required fields were
    # given values.
    foreach vendor_code $elements {
        set product_id [ecds_import_product_from_vendor_site $abbrev vendor $vendor_code]
        incr count
        if { $product_id == -1 } {
            ns_log Warning "upload-vendor-imports-2.tcl: Unable to import ${vendor_code}."
        } else {
            incr success_count
        }

    }
    # read next line of data file, depending on file type, or end read loop if error.
    set line_status [ns_getcsv $datafilefp elements]
}

if { $success_count == 1 } {
    set product_string "product"
} else {
    set product_string "products"
}

doc_body_append "</blockquote>

<p>Successfully imported $success_count $product_string out of [ec_decode $count "0" "0" [expr $count -1]].
See server log for details.
[ad_admin_footer]
"

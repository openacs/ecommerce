#  www/[ec_url_concat [ec_url] /admin]/products/supporting-files-upload.tcl
ad_page_contract {
  Supporting files upload.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id supporting-files-upload.tcl,v 3.2.2.2 2000/07/22 07:57:46 ron Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  product_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

set product_name [ec_product_name $product_id]

doc_body_append "[ad_admin_header "Supporting Files for $product_name"]

<h2>Supporting Files for $product_name</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] [list "one.tcl?[export_url_vars product_id]" "One"] "Supporting Files"]

<hr>
<h3>Current Supporting Files</h3>
<ul>
"


set dirname [db_string dirname_select "select dirname from ec_products where product_id=$product_id"]

# make sure there are no /'s in dirname
if { [regexp {/} $dirname] } {
    error "Invalid dirname."
}

if { ![empty_string_p $dirname] } {
    set subdirectory [ec_product_file_directory $product_id]

    set full_dirname "[ec_data_directory][ec_product_directory]$subdirectory/$dirname"

    # see what's in that directory
    set file_list [glob -nocomplain -directory $full_dirname *]

    foreach file_name $file_list {
      set file [lindex [file split $file_name] end]
      doc_body_append "<li><a href=\"/product-file/$subdirectory/$dirname/$file\">$file</a> \[<a href=\"supporting-file-delete?[export_url_vars file product_id]\">delete</a>]\n"
    }

    if { [string length $file_list] == 0 } {
	doc_body_append "No files found.\n"
    }
} else {
    doc_body_append "No directory found.\n"
}

doc_body_append "</ul>

<h3>Upload New File</h3>

<blockquote>
"
if { [string compare $dirname ""] != 0 } {
    doc_body_append "<form enctype=multipart/form-data method=post action=supporting-files-upload-2>
    [export_form_vars product_id]
    <input type=file size=10 name=upload_file>
    <input type=submit value=\"Continue\">
    </form>
    "
} else {
    doc_body_append "No directory found in which to upload files."
}

doc_body_append "</blockquote>

<blockquote>

Note that the picture of the product is not considered a supporting
file.  If you want to change it, go to
<a href=\"edit?[export_url_vars product_id]\">the regular product edit page</a>.

</blockquote>

[ad_admin_footer]
"

#  www/[ec_url_concat [ec_url] /admin]/products/supporting-files-upload.tcl
ad_page_contract {
  Supporting files upload.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  product_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

set product_name [ec_product_name $product_id]

set title "Supporting Files for $product_name"
set context [list [list index Products] $title]

set dirname [db_string dirname_select "select dirname from ec_products where product_id=$product_id"]

set comments ""
# make sure there are no /'s in dirname, and the dirname is not blank
set dirname_exists [expr { ![empty_string_p $dirname] && ![regexp {/} $dirname] }]
if { $dirname_exists } {
    set subdirectory [ec_product_file_directory $product_id]
    set full_dirname "[ec_data_directory][ec_product_directory]$subdirectory/$dirname"

    # see what's in that directory
    set file_list [glob -nocomplain -directory $full_dirname *]

    set file_list_html ""
    set files_count 0
    foreach file_name $file_list {
        set file [lindex [file split $file_name] end]
        if { [string match {product.[jg][pi][gf]} $file] } {
            # do not show it
        } elseif { [string match {product-thumbnail.jpg} $file] } {
            # do not show it
        } else {
            append file_list_html "<li><a href=\"[ec_url]product-file/$subdirectory/$dirname/$file\">$file</a> \[<a href=\"supporting-file-delete?[export_url_vars file product_id]\">delete</a>]</li>\n"
            incr files_count
        }
    }
} 

set export_product_id_html [export_url_vars product_id]
set export_form_product_id_html [export_form_vars product_id]

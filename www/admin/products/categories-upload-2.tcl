#  www/[ec_url_concat [ec_url] /admin]/products/categories-upload-2.tcl
#  added changes proposed by bug 486, 1195
ad_page_contract {
  Upload product category mappings.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  csv_file
  csv_file.tmpfile:tmpfile
}

ad_require_permission [ad_conn package_id] admin

if { [empty_string_p $csv_file] } {
    ad_return_error "Missing CSV File" "You must input the name of the .csv file on your local hard drive."
    return
}

set user_id [ad_get_user_id]
set ip [ns_conn peeraddr]

set title "Uploading Category Mappings"
set context [list [list index Products] $title]


# Get the name of the transfered data file

set unix_file_name ${csv_file.tmpfile}

# Check that the file is readable.

if { ![file readable $unix_file_name] } {
    doc_body_append "Cannot read file $unix_file_name"
    return
}

set datafilefp [open $unix_file_name]

set count 0
set success_count 0
set result_html ""

# nb: no header line
while { [ns_getcsv $datafilefp elements] != -1 } {
    incr count
    
    set sku [lindex $elements 0]
    set category_matches [lrange $elements 1 end]

    # Check if there is a product with the give sku.
    # Set product_id to NULL if there is no product with the given sku.
    set product_id [db_string product_check {select product_id from ec_products where sku = :sku;} -default ""]

    if { $product_id != "" } {
        foreach category_match_uc $category_matches {
            set category_match [string tolower $category_match_uc]

            set success 0

            set subsubcategory_id 0
            set subcategory_id 0
            set category_id 0

            # see if this matches any subsubcategories
            if {[db_0or1row find_subsubcategory "see xql"]} {
                # we will set all 3
            } elseif {[db_0or1row find_subcategory "see xql"]} {
                # set only category and sub
            } elseif {[db_0or1row find_category "see xql"]} {
                # set only category
            }

            append result_html "sku: $sku, category match: \"$category_match\" :: "

            if {$subsubcategory_id} {
                if { [catch {db_dml subsubcategory_insert ""} errmsg] } {
                    #error, probably already loaded this one
                    append result_html " already matched to subsubcategory $subsubcategory_name; "
                } else {
                    append result_html " matched to subsubcategory $subsubcategory_name; "
                    set success 1
                }
            }

            if {$subcategory_id} {
                if { [catch {db_dml subcategory_insert ""} errmsg] } {
                    #error, probably already loaded this one
                    append result_html " already matched to subcategory $subcategory_name; "
                } else {
                    append result_html " matched to subcategory $subcategory_name; "
                    set success 1
                }
            }

            if {$category_id} {
                if { [catch {db_dml category_insert ""} errmsg] } {
                    #error, probably already loaded this one
                    append result_html " already matched to category $category_name."
                } else {
                    append result_html " matched  to category $category_name."
                    set success 1
                }
            }

            if { ! $subsubcategory_id && ! $subcategory_id && ! $category_id } {
                append result_html " <font color=red>could not find matching category</font>"
            }

            if { $success } {
                incr success_count
            }

            append result_html "<br>\n"
            
        }
    } else {
        append result_html "<font color=red>could not find matching sku for: $sku</font><br>\n"
    }
}

if { $success_count == 1 } {
    set category_string "category mapping"
} else {
    set category_string "category mappings"
}


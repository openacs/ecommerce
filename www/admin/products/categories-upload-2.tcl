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

doc_body_append "[ad_admin_header "Uploading Category Mappings"]

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] "Uploading Categories"]

<hr>

<h3>Uploading Category Mappings</h3>

<blockquote>
"

set csv_file_name ${csv_file.tmpfile}

set csvfp [open $csv_file_name]

set count 0
set success_count 0
while { [ec_gets_char_delimited_line $csvfp elements] != -1 } {
    incr count
    # this line is a product
    set sku [lindex $elements 0]
# upload category id from file
    set category [lindex $elements 1]
# upload subcategory id from file
    set subcategory [lindex $elements 2]
# upload subsubcategory id from file
    set subsubcategory [lindex $elements 3]


    # Check if there is a product with the give sku.
    # Set product_id to NULL if there is no
    # product with the given sku.
    set product_id [db_string product_check {select product_id from ec_products where sku = :sku;} -default ""]

    # Modified by RH on 05/05/03
    # Match the product with the given (sub)(sub)category.
    if { $product_id != "" } {

	# see if this matches any subsubcategories
	set subsubmatch_p 0
	db_foreach subsubcategories_select "
	select c.category_id, c.category_name, s.subcategory_id, s.subcategory_name, ss.subsubcategory_id, ss.subsubcategory_name from ec_subsubcategories ss, ec_subcategories s, ec_categories c
        where c.category_id = s.category_id
        and s.subcategory_id = ss.subcategory_id
        and :subsubcategory = ss.subsubcategory_id" {
#           previous line changed to directly match category id
#          so that there is no mistake in placement of product to categories
	    set subsubmatch_p 1

	    # add this product to the matched subsubcategory
	    set sql "insert into ec_subsubcategory_product_map (product_id, subsubcategory_id, publisher_favorite_p, last_modified, last_modifying_user, modified_ip_address) values (:product_id, :subsubcategory_id, 'f', sysdate, :user_id, :ip)"
	    if { [catch {db_dml subsubcategory_insert $sql} errmsg] } {
		#error, probably already loaded this one
	    } else {
		doc_body_append "Matched $category to subsubcategory $subsubcategory_name in subcategory $subcategory_name, category $category_name.<br>\n"
	    }

	    # now add it to the subcategory that owns this subsubcategory
	    set sql "insert into ec_subcategory_product_map (product_id, subcategory_id, publisher_favorite_p, last_modified, last_modifying_user, modified_ip_address) values (:product_id, :subcategory_id, 'f', sysdate, :user_id, :ip)"
	    if { [catch {db_dml subcategory_insert $sql} errmsg] } {
		#error, probably already loaded this one
	    }

	    # now add it to the category that owns this subcategory
	    set sql "insert into ec_category_product_map (product_id, category_id, publisher_favorite_p, last_modified, last_modifying_user, modified_ip_address) values (:product_id, :category_id, 'f', sysdate, :user_id, :ip)"
	    if { [catch {db_dml unused_sub $sql} errmsg] } {
		#error, probably already loaded this one
	    }
	}

	# see if this matches any subcategories
	set submatch_p 0
	db_foreach subcategories_select "
	select c.category_id, c.category_name, s.subcategory_id,
	s.subcategory_name from ec_subcategories s, ec_categories c
	where c.category_id = s.category_id
	and :subcategory = subcategory_id" {
#           previous line changed to directly match category id
#          so that there is no mistake in placement of product to categories
	    set submatch_p 1
	    
	    # add this product to the matched subcategory
	    set sql "insert into ec_subcategory_product_map (product_id, subcategory_id, publisher_favorite_p, last_modified, last_modifying_user, modified_ip_address) values (:product_id, :subcategory_id, 'f', sysdate, :user_id, :ip)"
	    if { [catch {db_dml subcategory_insert $sql} errmsg] } {
		#error, probably already loaded this one
	    } else {
		doc_body_append "Matched $category to subcategory $subcategory_name in category $category_name<br>\n"
	    }
	    # now add it to the category that owns this subcategory
	    set sql "insert into ec_category_product_map (product_id, category_id, publisher_favorite_p, last_modified, last_modifying_user, modified_ip_address) values (:product_id, :category_id, 'f', sysdate, :user_id, :ip)"
	    if { [catch {db_dml unused_sub $sql} errmsg] } {
		#error, probably already loaded this one
	    }
	}

	# see if this matches any categories
	set match_p 0
	db_foreach category_match_select "select category_id, category_name from ec_categories where :category = category_id" {
#           previous line changed to directly match category id
#          so that there is no mistake in placement of product to categories
	    set match_p 1
	    set sql "insert into ec_category_product_map (product_id, category_id, publisher_favorite_p, last_modified, last_modifying_user, modified_ip_address) values (:product_id, :category_id, 'f', sysdate, :user_id, :ip)"
	    if { [catch {db_dml category_insert $sql} errmsg] } {
		#error, probably already loaded this one
	    } else {
		doc_body_append "Matched $category to category $category_name<br>\n"
	    }
	}
	if { ! ($match_p || $submatch_p || $subsubmatch_p) } {
	    doc_body_append "<font color=red>Datafile row $count : Could not find matching category reference for item (sku: $sku) with category ref: $category : $subcategory : $subsubcategory</font><br>\n"
	} else {
	    incr success_count
	}
    }
}

if { $success_count == 1 } {
    set category_string "category mapping"
} else {
    set category_string "category mappings"
}

doc_body_append "<p>Done loading $success_count $category_string out of $count.

</blockquote>

[ad_admin_footer]
"

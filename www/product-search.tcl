ad_page_contract {
    @param search_text
    @param combocategory_id:optional
    @param usca_p:optional
    
    This page searches for products either within a category (if specified) or
    within all products

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author Bart Teeuwisse <bart.teeuwisse@7-sisters.com>
    @revision-date April 2002

} {
    search_text
    {combocategory_id ""}
    {category_id ""}
    {subcategory_id ""}
    usca_p:optional
}

set user_id [ad_verify_and_get_user_id]

# user session tracking
set user_session_id [ec_get_user_session_id]

# user sessions:
# 1. get user_session_id from cookie
# 2. if user has no session (i.e. user_session_id=0), attempt to set it if it hasn't been
#    attempted before
# 3. if it has been attempted before,
#    (a) if they have no offer_code, then do nothing
#    (b) if they have a offer_code, tell them they need cookies on if they
#        want their offer price
# 4. Log this category_id, search_text into the user session

# Decode the combo of category and subcategory ids
if { ![empty_string_p $combocategory_id] } {
    set category_id [lindex [split $combocategory_id "|"] 0]
    set subcategory_id [lindex [split $combocategory_id "|"] 1]
} else {
    set category_id ""
    set subcategory_id ""
}

ec_create_new_session_if_necessary [export_url_vars category_id search_text] cookies_are_not_required
if { [string compare $user_session_id "0"] != 0 } {
    db_dml insert_search_text_to_session_info "insert into ec_user_session_info (user_session_id, category_id, search_text) values (:user_session_id, :category_id, :search_text)"
}

if { ![empty_string_p $subcategory_id] && $subcategory_id > 0} {
    set category_name "[ec_system_name] > [db_string get_subcategory_name "select category_name || ' > ' || subcategory_name from ec_categories c, ec_subcategories s where s.subcategory_id=:subcategory_id and c.category_id=s.category_id"] search results for '$search_text'"
} else {
    if { ![empty_string_p $category_id] } {
	set category_name "[ec_system_name] > [db_string get_category_name "select category_name from ec_categories where category_id=:category_id"] search results for '$search_text'"
    } else {
	set category_name "[ec_system_name] search results for '$search_text'"
    }
}

if { ![empty_string_p $subcategory_id] && $subcategory_id > 0} {
    set query_string [db_map search_subcategory] 
    # select p.product_name, p.product_id, p.dirname, p.one_line_description,pseudo_contains(p.product_name || p.one_line_description || p.detailed_description || p.search_keywords, :search_text) as score
    # from ec_products_searchable p, ec_subcategory_product_map c
    # where c.subcategory_id=:subcategory_id
    # and p.product_id=c.product_id
    # and pseudo_contains(p.product_name || p.one_line_description ||  p.detailed_description || p.search_keywords, :search_text) > 0
    # order by score desc
} else {
    if { ![empty_string_p $category_id] } {
	set query_string [db_map search_category] 
	# select p.product_name, p.product_id, p.dirname, p.one_line_description,pseudo_contains(p.product_name || p.one_line_description || p.detailed_description || p.search_keywords, :search_text) as score
	# from ec_products_searchable p, ec_category_product_map c
	# where c.category_id=:category_id
	# and p.product_id=c.product_id
	# and pseudo_contains(p.product_name || p.one_line_description ||  p.detailed_description || p.search_keywords, :search_text) > 0
	# order by score desc
    } else {
	set query_string [db_map search_all]
	# select p.product_name, p.product_id, p.dirname, p.one_line_description,pseudo_contains(p.product_name || p.one_line_description || p.detailed_description || p.search_keywords, :search_text) as score
	# from ec_products_searchable p
	# where pseudo_contains(p.product_name || p.one_line_description ||  p.detailed_description || p.search_keywords, :search_text) > 0
	# order by score desc
    }
}

set search_string ""
set search_count 0
db_foreach get_product_listing_from_search $query_string {
    incr search_count
    append search_string "
      <table width=90%>
        <tr>
          <td valign=center>
            <table>
              <tr><td><a href=\"product?[export_url_vars product_id]\">$product_name</a></td></tr>
              <tr><td>$one_line_description</td></tr>
              <tr><td>[ec_price_line $product_id $user_id ""]</td></tr>
            </table>
          </td>
          <td align=right valign=top>[ec_linked_thumbnail_if_it_exists $dirname "t" "t"]</td>
        </tr>
      </table>"
}

if { $search_count == 0 } {
    set search_results "No products found."
} else {
    set search_results " $search_count item[ec_decode $search_count "1" "" "s"] found.<p>$search_string"
}
db_release_unused_handles
ad_return_template

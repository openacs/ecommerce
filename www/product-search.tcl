#  www/ecommerce/product-search.tcl
ad_page_contract {
  @param search_text
  @param category_id:optional
  @param usca_p:optional
    
  This page searches for products either within a category (if specified) or
  within all products

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id product-search.tcl,v 3.3.2.4 2000/07/21 03:59:29 ron Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  search_text
  {category_id:integer,notnull ""}
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

ec_create_new_session_if_necessary [export_url_vars category_id search_text] cookies_are_not_required
# type6

if { [string compare $user_session_id "0"] != 0 } {
    db_dml insert_search_text_to_session_info "insert into ec_user_session_info (user_session_id, category_id, search_text) values (:user_session_id, :category_id, :search_text)"
}

if { ![empty_string_p $category_id] } {
    set category_name [db_string get_category_name "select category_name from ec_categories where category_id=:category_id"]
} else {
    set category_name ""
}

if { ![empty_string_p $category_id] } {
    set query_string "select p.product_name, p.product_id, p.dirname, p.one_line_description,pseudo_contains(p.product_name || p.one_line_description || p.detailed_description || p.search_keywords, :search_text) as score
    from ec_products_searchable p, ec_category_product_map c
    where c.category_id=:category_id
    and p.product_id=c.product_id
    and pseudo_contains(p.product_name || p.one_line_description ||  p.detailed_description || p.search_keywords, :search_text) > 0
    order by score desc"
} else {
    set query_string "select p.product_name, p.product_id, p.dirname, p.one_line_description,pseudo_contains(p.product_name || p.one_line_description || p.detailed_description || p.search_keywords, :search_text) as score
    from ec_products_searchable p
    where pseudo_contains(p.product_name || p.one_line_description ||  p.detailed_description || p.search_keywords, :search_text) > 0
    order by score desc"
}

set search_string ""
set search_count 0

db_foreach get_product_listing_from_search $query_string {

    incr search_count

    append search_string "<table width=90%>
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
</table>
"
}

if { $search_count == 0 } {
    set search_results "No products found."
} else {
    set search_results " $search_count item[ec_decode $search_count "1" "" "s"] found.<p>$search_string"
}
db_release_unused_handles
ec_return_template

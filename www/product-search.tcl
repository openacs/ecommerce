ad_page_contract {
    @param search_text
    @param combocategory_id:optional
    @param category_id:optional
    @param subcategory_id:optional
    @param combocategory_id:optional
    @param rows_per_page:optional How many products to display on the page
    @param start_row:optional Where to begin from
    @param usca_p:optional
    
    This page searches for products either within a category (if specified) or
    within all products

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002
} {
    search_text
    {combocategory_id ""}
    {category_id ""}
    {subcategory_id ""}
    {rows_per_page:naturalnum {[ad_parameter -package_id [ec_id] ProductsToDisplayPerPage ecommerce]}}
    {start_row:naturalnum "0"}
    usca_p:optional
}

set user_id [ad_verify_and_get_user_id]

# Is search request originating from a page from this site? 
# if not, cookies are created for each image, so consider skiping presenting images
# when referrer is not this site. A better solution would be 
# to move the product images to a /resources dir

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
}

# filter extra spaces
regsub -all -- {\s+} $search_text { } search_text]
set search_text "[string trim $search_text]"
# filter overflow attempts from really long search strings
set search_text "[string range $search_text 0 100 ]"

ec_create_new_session_if_necessary [export_url_vars category_id subcategory_id subsubcategory_id rows_per_page start_row search_text] cookies_are_not_required
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
    set query_count_string [db_map search_count_subcategory] 
    # select p.product_name, p.product_id, p.dirname, p.one_line_description,pseudo_contains(p.product_name || p.one_line_description || p.detailed_description || p.search_keywords, :search_text) as score
    # from ec_products_searchable p, ec_subcategory_product_map c
    # where c.subcategory_id=:subcategory_id
    # and p.product_id=c.product_id
    # and pseudo_contains(p.product_name || p.one_line_description ||  p.detailed_description || p.search_keywords, :search_text) > 0
    # order by score desc limit :rows_per_page offset :start_row
} else {
    if { ![empty_string_p $category_id] } {
	set query_string [db_map search_category] 
	set query_count_string [db_map search_count_category] 
	# select p.product_name, p.product_id, p.dirname, p.one_line_description,pseudo_contains(p.product_name || p.one_line_description || p.detailed_description || p.search_keywords, :search_text) as score
	# from ec_products_searchable p, ec_category_product_map c
	# where c.category_id=:category_id
	# and p.product_id=c.product_id
	# and pseudo_contains(p.product_name || p.one_line_description ||  p.detailed_description || p.search_keywords, :search_text) > 0
	# order by score desc limit :rows_per_page offset :start_row
    } else {
	set query_string [db_map search_all]
	set query_count_string [db_map search_count_all]
	# select p.product_name, p.product_id, p.dirname, p.one_line_description,pseudo_contains(p.product_name || p.one_line_description || p.detailed_description || p.search_keywords, :search_text) as score
	# from ec_products_searchable p
	# where pseudo_contains(p.product_name || p.one_line_description ||  p.detailed_description || p.search_keywords, :search_text) > 0
	# order by score desc limit :rows_per_page offset :start_row
    }
}

set search_string ""
set page_count 0
#  make  search_count equal to count(*) of query
# getting the count of search results requires a second db hit, 
# which is magnitudes better than the tcl filtering that used to be in this loop
db_1row get_search_count $query_count_string 
set have_how_many_more_p "f"
set end_row_of_next_page [expr $start_row + (2 * $rows_per_page)]
db_foreach get_product_listing_from_search $query_string {

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

    incr page_count
}
set last_row_this_page [expr $page_count + $start_row ]
if { $search_count > $end_row_of_next_page } {
	# we know there are at least how_many more items to display next time
	set have_how_many_more_p "t"
} 

if { $start_row >= $rows_per_page } {
    set prev_link "<a href=[ad_conn url]?[export_url_vars category_id subcategory_id subsubcategory_id rows_per_page search_text]&start_row=[expr $start_row - $rows_per_page]>Previous $rows_per_page</a>"
} else {
    set prev_link ""
}

if { [string equal $have_how_many_more_p "t"] } {
    set next_link "<a href=[ad_conn url]?[export_url_vars category_id subcategory_id subsubcategory_id rows_per_page search_text]&start_row=[expr $start_row + $rows_per_page]>Next $rows_per_page</a>"
} else {
    set number_of_remaining_products [expr $search_count - $start_row - $rows_per_page ]
    if { $number_of_remaining_products > 0 } {
	set next_link "<a href=[ad_conn url]?[export_url_vars category_id subcategory_id subsubcategory_id rows_per_page search_text]&start_row=[expr $start_row + $rows_per_page]>Next $number_of_remaining_products</a>"
    } else {
	set next_link ""
    }
}

if { [empty_string_p $next_link] || [empty_string_p $prev_link] } {
    set separator ""
} else {
    set separator "&nbsp;|&nbsp;"
}

if { $search_count == 0 } {
    set search_results "No products found."
} else {
    set search_results "<p> $search_count [ec_decode $search_count "1" "item found." "items found, most relevant first."]</p>"
    if { $start_row != 0 || $search_count > $rows_per_page } {
        if { [info exists last_row_this_page] } {
            append search_results "<p>Showing items [expr $start_row + 1] to $last_row_this_page.</p>"
        } else {
            append search_results "<p>Display scope out of range of search results.</p>"
        }
    }
    append search_results "${search_string}${prev_link}${separator}${next_link}"
}
set context_bar [template::adp_parse [acs_root_dir]/packages/[ad_conn package_key]/www/contextbar [list context_addition [list "[ec_system_name] search results"]]]
set ec_system_owner [ec_system_owner]

db_release_unused_handles
ad_return_template

#  www/ecommerce/index.tcl
ad_page_contract {
    @param usca_p
    @param how_many
    @param start
  @author
  @creation-date
  @cvs-id index.tcl,v 3.4.2.8 2000/08/21 20:14:29 tzumainn Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    usca_p:optional
    {how_many:naturalnum {[ad_parameter -package_id [ec_id] ProductsToDisplayPerPage ecommerce]}}
    {start "0"}
}

# see if they're logged in
set user_id [ad_verify_and_get_user_id]
if { $user_id != 0 } {
    set user_name [db_string get_user_name "select first_names || ' ' || last_name from cc_users where user_id=:user_id"]
} else {
    set user_name ""
}

# for the template
if { $user_id == 0 } {
    set user_is_logged_on 0
} else {
    set user_is_logged_on 1
}

# user session tracking

set user_session_id [ec_get_user_session_id]

ec_create_new_session_if_necessary "" cookies_are_not_required

# Log the user as the user_id for this session
if { $user_is_logged_on && ![string equal $user_session_id "0"]} {
    db_dml update_session_user_id "update ec_user_sessions set user_id=:user_id where user_session_id = :user_session_id"
}

set ec_user_string ""
set register_url "/register?return_url=[ns_urlencode [ec_url]]"

# we'll show a search widget at the top if there are categories to search in
if { ![empty_string_p [db_string get_check_of_categories "select 1 from dual where exists (select 1 from ec_categories)" -default ""]] } {
    set search_widget [ec_search_widget]
} else {
    set search_widget ""
}

set recommendations_if_there_are_any ""

set header_to_print "<b>We Recommend</b><p><blockquote>"
set header_printed 0

if { [ad_parameter -package_id [ec_id] UserClassApproveP ecommerce] } {
    set user_class_approved_p_clause "and user_class_approved_p = 't'"
} else {
    set user_class_approved_p_clause ""
}

db_foreach get_produc_recs "select p.product_name, p.product_id, p.dirname, r.recommendation_text
from ec_products_displayable p, ec_product_recommendations r
where p.product_id=r.product_id
and category_id is null 
and subcategory_id is null 
and subsubcategory_id is null
and (r.user_class_id is null or r.user_class_id in (select user_class_id
     from ec_user_class_user_map 
     where user_id = :user_id
     $user_class_approved_p_clause))
and r.active_p='t'" {

    if { !$header_printed } {
        append recommendations_if_there_are_any $header_to_print
	set header_printed 1
    }
    append recommendations_if_there_are_any "<table>
<tr>
<td valign=top>[ec_linked_thumbnail_if_it_exists $dirname "f" "t"]</td>
<td valign=top><a href=\"product?[export_url_vars product_id]\">$product_name</a>
<p>
$recommendation_text
</td>
</tr>
</table>
"
}

append recommendations_if_there_are_any "</blockquote>"

if { [ad_parameter -package_id [ec_id] SellGiftCertificatesP ecommerce] == 1 } {
    set gift_certificates_are_allowed 1
} else {
    set gift_certificates_are_allowed 0
}
set products ""

set have_how_many_more_p f
set count 0

# find all top-level products (those that are uncategorized)
db_foreach get_tl_products "select
p.product_name, p.product_id, p.one_line_description
from ec_products_searchable p
where not exists (select 1 from ec_category_product_map m where p.product_id = m.product_id)
order by p.product_name" {


    if { $count >= $start && [expr $count - $start] < $how_many } {

	append products "<table><tr valign=top><td>[expr $count + 1]</td><td><a href=\"product?product_id=$product_id\"><b>$product_name</b></a><br>$one_line_description</td></tr></table>\n"
    }
    incr count
    if { $count > [expr $start + (2 * $how_many)] } {
	# we know there are at least how_many more items to display next time
	set have_how_many_more_p t
	break
    } else {
	set have_how_many_more_p f
    }
}

append products ""

if { $start >= $how_many } {
    set prev_link "<a href=[ad_conn url]?[export_url_vars category_id subcategory_id subsubcategory_id how_many]&start=[expr $start - $how_many]>Previous $how_many</a>"
} else {
    set prev_link ""
}

if { $have_how_many_more_p == "t" } {
    set next_link "<a href=[ad_conn url]?[export_url_vars category_id subcategory_id subsubcategory_id how_many]&start=[expr $start + $how_many]>Next $how_many</a>"
} else {
    set number_of_remaining_products [expr $count - $start - $how_many]
    if { $number_of_remaining_products > 0 } {
	set next_link "<a href=[ad_conn url]?[export_url_vars category_id subcategory_id subsubcategory_id how_many]&start=[expr $start + $how_many]>Next $number_of_remaining_products</a>"
    } else {
	set next_link ""
    }
}

if { [empty_string_p $next_link] || [empty_string_p $prev_link] } {
    set separator ""
} else {
    set separator "|"
}
db_release_unused_handles

ec_return_template

ad_page_contract {

    This one file is used to browse not only categories, but also subcategories and subsubcategories.
  
    @param category_id The ID of the category
    @param subcategory_id The ID of the subcategory
    @param subsubcategory_id The possible ID of any subsubcategory
    @param how_many How many products to display on the page
    @param start Where to begin from
    @param usca_p User session begun or not

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse <barrt.teeuwisse@7-sisters.com>
    @revision-date May 2002
} {
    category_id:notnull,naturalnum
    subcategory_id:optional,naturalnum
    subsubcategory_id:optional,naturalnum
    {how_many:naturalnum {[ad_parameter -package_id [ec_id] ProductsToDisplayPerPage ecommerce]}}
    {start:naturalnum "0"}
    usca_p:optional
}

proc ident {x} {return $x}
proc have {var} { upvar $var x; return [expr {[info exists x] && [string compare $x "0"] != 0}]}
proc in_subcat    {} {return [uplevel {have subcategory_id}]}
proc in_subsubcat {} {return [uplevel {have subsubcategory_id}]}
proc at_bottom_level_p {} {return [uplevel in_subsubcat]}

set sub ""
if [in_subcat]    {append sub "sub"} else {set subcategory_id 0}
if [in_subsubcat] {append sub "sub"} else {set subsubcategory_id 0}

set product_map()       "ec_category_product_map"
set product_map(sub)    "ec_subcategory_product_map"
set product_map(subsub) "ec_subsubcategory_product_map"

set user_session_id [ec_get_user_session_id]

# see if they're logged in
set user_id [ad_verify_and_get_user_id]
if { $user_id != 0 } {
    set user_name [db_string get_user_name "select first_names || ' ' || last_name from cc_users where user_id=:user_id"]
} else {
    set user_name ""
}

# user sessions:
# 1. get user_session_id from cookie
# 2. if user has no session (i.e. user_session_id=0), attempt to set it if it hasn't been
#    attempted before
# 3. if it has been attempted before,
#    (a) if they have no offer_code, then do nothing
#    (b) if they have a offer_code, tell them they need cookies on if they
#        want their offer price
# 4. Log this category_id into the user session

ec_create_new_session_if_necessary [export_url_vars category_id subcategory_id subsubcategory_id how_many start] cookies_are_not_required
# type4

if { [string compare $user_session_id "0"] != 0 } {
    db_dml grab_new_session_id "
    insert into ec_user_session_info (user_session_id, category_id)
    values (:user_session_id, :category_id)
    "
}

set category_name [db_string get_category_name "select category_name from ec_categories where category_id=:category_id"]

set subcategory_name ""
if [have subcategory_id] {
    set subcategory_name [db_string get_subcat_name "select subcategory_name from ec_subcategories where subcategory_id=:subcategory_id"]
}

set subsubcategory_name ""
if [have subsubcategory_id] {
    set subsubcategory_name [db_string get_subsubcat_name "select subsubcategory_name from ec_subsubcategories where subsubcategory_id=:subsubcategory_id"]
}

#==============================
# recommendations

# Recommended products in this category

set recommendations "<table width=100%>"

if { [ad_parameter -package_id [ec_id] UserClassApproveP ecommerce] } {
    set user_class_approved_p_clause "and user_class_approved_p = 't'"
} else {
    set user_class_approved_p_clause ""
}

db_foreach get_recommended_products "
    select p.product_id, p.product_name, p.dirname, r.recommendation_text, o.offer_code
    from ec_product_recommendations r, ec_products_displayable p left outer join ec_user_session_offer_codes o on (p.product_id = o.product_id and user_session_id = :user_session_id)
    where p.product_id = r.product_id
    and r.${sub}category_id=:${sub}category_id
    and r.active_p='t'
    and (r.user_class_id is null or r.user_class_id in (select user_class_id 
							from ec_user_class_user_map m 
							where user_id=:user_id
							$user_class_approved_p_clause))
    order by p.product_name" {

    append recommendations "
	  <tr>
	    <td valign=top>[ec_linked_thumbnail_if_it_exists $dirname "f" "t"]</td>
	    <td valign=top><a href=\"product?[export_url_vars product_id]\">$product_name</a>
	      <p>$recommendation_text</p>
	    </td>
	    <td valign=top align=right>[ec_price_line $product_id $user_id $offer_code]</td>
         </tr>"
}

if {[string equal $recommendations "<table width=100%>"]} {
    set recommendations ""
} else {
    append recommendations "</table>"
}

#==============================
# products

# All products in the "category" and not in "subcategories"

set exclude_subproducts ""
if ![at_bottom_level_p] {
  set exclude_subproducts "
and not exists (
select 'x' from $product_map(sub$sub) s, ec_sub${sub}categories c
                 where p.product_id = s.product_id
                   and s.sub${sub}category_id = c.sub${sub}category_id
                   and c.${sub}category_id = :${sub}category_id)
"
}

set products "<table width=90%>"

set have_how_many_more_p f
set count 0

db_foreach get_regular_product_list "
    select p.product_id, p.product_name, p.one_line_description, o.offer_code
    from $product_map($sub) m, ec_products_searchable p left outer join ec_user_session_offer_codes o on (p.product_id = o.product_id and user_session_id = :user_session_id)
    where p.product_id = m.product_id
    and m.${sub}category_id = :${sub}category_id
    $exclude_subproducts
    order by p.product_name" {

    if { $count >= $start && [expr $count - $start] < $how_many } {

	append products "
	      <tr valign=top>
	        <td>[expr $count + 1]</td>
	        <td colspan=2><a href=\"product?product_id=$product_id\"><b>$product_name</b></a></td>
	      </tr>
	      <tr valign=top>
		<td></td>
		<td>$one_line_description</td>
		<td align=right>[ec_price_line $product_id $user_id $offer_code]</td>
	      </tr>"
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

append products "</table>"

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

#==============================
# subcategories

set subcategories ""
if ![at_bottom_level_p] {
  db_foreach get_subcategories "
SELECT * from ec_sub${sub}categories c
 WHERE ${sub}category_id = :${sub}category_id
   AND exists (
       SELECT 'x' from ec_products_displayable p, $product_map(sub$sub) s
        where p.product_id = s.product_id
          and s.sub${sub}category_id = c.sub${sub}category_id
     )
 ORDER BY sort_key, sub${sub}category_name
" {

  
      append subcategories "<li><a href=category-browse-sub${sub}category?[export_url_vars category_id subcategory_id subsubcategory_id]>[eval "ident \$sub${sub}category_name"]</a>"
  }
}

set the_category_id   $category_id
set the_category_name [eval "ident \$${sub}category_name"]
db_release_unused_handles
ad_return_template

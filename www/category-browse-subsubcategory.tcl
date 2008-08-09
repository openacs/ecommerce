ad_page_contract {

    This one file is used to browse not only categories, but also subcategories and subsubcategories.
    
    @param category_id The ID of the category
    @param subcategory_id The ID of the subcategory
    @param subsubcategory_id The ID of the subsubcategory
    @param how_many How many products to show on a page
    @param start Which product to start at
    @param usca_p User session begun or not

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revision Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date May 2002
} {
    category_id:naturalnum,notnull
    subcategory_id:optional,naturalnum
    subsubcategory_id:optional,naturalnum
    {how_many:naturalnum {[ad_parameter -package_id [ec_id] ProductsToDisplayPerPage ecommerce]}}
    {start:naturalnum "0"}
    usca_p:optional
}

set sub ""
if [ec_in_subcat]    {append sub "sub"} else {set subcategory_id 0}
if [ec_in_subsubcat] {append sub "sub"} else {set subsubcategory_id 0}

set product_map()       "ec_category_product_map"
set product_map(sub)    "ec_subcategory_product_map"
set product_map(subsub) "ec_subsubcategory_product_map"

set user_session_id [ec_get_user_session_id]

# See if they're logged in

set user_id [ad_conn user_id]
if { $user_id != 0 } {
    set user_name [db_string get_full_name "select first_names || ' ' || last_name from cc_users where user_id=:user_id"]
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
    db_dml grab_new_session_id "insert into ec_user_session_info (user_session_id, category_id) values (:user_session_id, :category_id)"
}

set category_name [db_string get_category_name "select category_name from ec_categories where category_id=:category_id"]

set subcategory_name ""
if [ec_have subcategory_id] {
    set subcategory_name [db_string get_subcat_name "select subcategory_name from ec_subcategories where subcategory_id=:subcategory_id"]
}

set subsubcategory_name ""
if [ec_have subsubcategory_id] {
    set subsubcategory_name [db_string get_subsubcat_name "select subsubcategory_name from ec_subsubcategories where subsubcategory_id=:subsubcategory_id"]
}

#==============================
# recommendations

# Recommended products in this category

set recommendations {<table width="100%">}

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
if {[string equal $recommendations {<table width="100%">}]} {
    set recommendations ""
} else {
    append recommendations "</table>"
}

#==============================
# products

# All products in the "category" and not in "subcategories"

set exclude_subproducts ""
if ![ec_at_bottom_level_p] {
    set exclude_subproducts "
and not exists (
		select 'x' from $product_map(sub$sub) s, ec_sub${sub}categories c
		where p.product_id = s.product_id
		and s.sub${sub}category_id = c.sub${sub}category_id
		and c.${sub}category_id = :${sub}category_id)
"
}

set count 0

# TODO: memoize
# NOTE: careful if you do cache this since the code block calculates per-user specials, and also change implementation of count
db_multirow -extend {
                    thumbnail_url
                    thumbnail_height
                    thumbnail_width
                    price_line
                    } products get_regular_product_list "sql in db specific xql files" {
                        
                        if {[array exists thumbnail_info]} {
                            unset thumbnail_info
                        }
                        array set thumbnail_info [ecommerce::resource::image_info -type Thumbnail -product_id $product_id -dirname $dirname]
                        if {[array size thumbnail_info]} {
                            set thumbnail_url $thumbnail_info(url)
                            set thumbnail_width $thumbnail_info(width)
                            set thumbnail_height $thumbnail_info(height)
                        } else {
                            # must blank them out, otherwise they would still be in scope
                            set thumbnail_url ""
                            set thumbnail_width ""
                            set thumbnail_height ""
                        }

                        set price_line [ec_price_line $product_id $user_id $offer_code]

                        incr count
                    }

# what if start is < how many? shouldn't happen I guess...
if { $start >= $how_many } {
    set prev_url [export_vars -base [ad_conn url] -override {{start {[expr $start - $how_many]}}} {category_id subcategory_id subsubcategory_id how_many}]
}

set how_many_more [expr $count - $start - $how_many + 1]

if { $how_many_more > 0 } {
    set next_url [export_vars -base [ad_conn url] -override {{start {[expr $start + $how_many]}}} {category_id subcategory_id subsubcategory_id how_many}]

    if { $how_many_more >= $how_many } {
        set how_many_next $how_many
    } else {
        set how_many_next $how_many_more
    }
}

set end [expr $start + $how_many - 1]

#==============================
# subcategories

set subcategories ""
if ![ec_at_bottom_level_p] {
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

    
    append subcategories "<li><a href=category-browse-sub${sub}category?[export_url_vars category_id subcategory_id subsubcategory_id]>[eval "ec_ident \$sub${sub}category_name"]</a>"
}
}

set the_category_id $category_id
set the_category_name [eval "ec_ident \$${sub}category_name"]
set context_bar [template::adp_parse [acs_root_dir]/packages/[ad_conn package_key]/www/contextbar [list context_addition [list [list "category-browse?category_id=$the_category_id" $category_name] [list "category-browse-subcategory?category_id=$the_category_id&amp;subcategory_id=$subcategory_id" $subcategory_name] $the_category_name]]]
set ec_system_owner [ec_system_owner]
db_release_unused_handles
ad_return_template

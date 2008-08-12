ad_page_contract {

    This one file is used to browse not only categories, but also subcategories and subsubcategories.
  
    @param category_id The ID of the category
    @param subcategory_id The ID of the subcategory
    @param subsubcategory_id The possible ID of any subsubcategory
    @param how_many How many products to display on the page
    @param start_row Where to begin from
    @param usca_p User session begun or not

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date May 2002
} {
    category_id:notnull,naturalnum
    subcategory_id:optional,naturalnum
    subsubcategory_id:optional,naturalnum
    {how_many:naturalnum {[ad_parameter -package_id [ec_id] ProductsToDisplayPerPage ecommerce]}}
    {start_row:naturalnum "1"}
    usca_p:optional
}

set sub ""
if [ec_in_subcat]    {append sub "sub"} else {set subcategory_id 0}
if [ec_in_subsubcat] {append sub "sub"} else {set subsubcategory_id 0}

set product_map()       "ec_category_product_map"
set product_map(sub)    "ec_subcategory_product_map"
set product_map(subsub) "ec_subsubcategory_product_map"

set user_session_id [ec_get_user_session_id]

# see if they're logged in
set user_id [ad_conn user_id]
if { $user_id != 0 } {
    acs_user::get -user_id $user_id -array user_info
    set user_name "$user_info(first_names) $user_info(last_name)"

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

ec_create_new_session_if_necessary [export_url_vars category_id subcategory_id subsubcategory_id how_many start_row] cookies_are_not_required
# type4

# this is expensive - do we really need to log this every time? can we write to a file for batched reading later?
if { [string compare $user_session_id "0"] != 0 } {
    db_dml grab_new_session_id "
    insert into ec_user_session_info (user_session_id, category_id)
    values (:user_session_id, :category_id)
    "
}

set category_name [db_string -cache_key "ec-category_name-${category_id}"  get_category_name "select category_name from ec_categories where category_id=:category_id"]

set subcategory_name ""
if { [ec_have subcategory_id] } {
    set subcategory_name [db_string -cache_key "ec-subcategory_name-${subcategory_id}" get_subcat_name "select subcategory_name from ec_subcategories where subcategory_id=:subcategory_id"]
}

set subsubcategory_name ""
if { [ec_have subsubcategory_id] } {
    set subsubcategory_name [db_string -cache_key "ec-subsubcategory_name-${subsubcategory_id}" get_subsubcat_name "select subsubcategory_name from ec_subsubcategories where subsubcategory_id=:subsubcategory_id"]
}

#==============================
# recommendations

# Recommended products in this category

if { [ad_parameter -package_id [ec_id] UserClassApproveP ecommerce] } {
    set user_class_approved_p_clause "and user_class_approved_p = 't'"
} else {
    set user_class_approved_p_clause ""
}

# when caching the db results, it must be limited to the (sub)category and also the user
# since per-user prices are calculated
# TODO: actually, it could be by offer code, which would allow less caching
upvar 0 ${sub}category_id cat_id
set cache_key_prefix "ec-${sub}subcategory-browse-products-${cat_id}-${user_id}"
ns_log Notice "using cache_key_prefix: $cache_key_prefix"

db_multirow -extend {
                     product_url price_line thumbnail_url thumbnail_width thumbnail_height
                    } -cache_key ${cache_key_prefix}-recommendations recommendations get_recommended_products "see xql" {
                        set price_line [ec_price_line $product_id $user_id $offer_code]
                        set product_url [export_vars -base product -override { product_id $product_id }]

                        if {[array exists thumbnail_info]} {
                            unset thumbnail_info
                        }
                        ns_log Notice [ecommerce::resource::image_info -type Thumbnail -product_id $product_id -dirname $dirname]
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
                    }

#==============================
# products

# All products in the "category" and not in "subcategories"

set exclude_subproducts ""
if { ![ec_at_bottom_level_p] } {
  set exclude_subproducts "
and not exists (
select 'x' from $product_map(sub$sub) s, ec_sub${sub}categories c
                 where p.product_id = s.product_id
                   and s.sub${sub}category_id = c.sub${sub}category_id
                   and c.${sub}category_id = :${sub}category_id)
"
}


db_multirow -extend {
                    thumbnail_url
                    thumbnail_height
                    thumbnail_width
                    price_line
                    } -cache_key ${cache_key_prefix}-products products get_regular_product_list "sql in db specific xql files" {

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

                    }

# what if start_row is < how many? shouldn't happen I guess...
if { $start_row >= $how_many } {
    set prev_url [export_vars -base [ad_conn url] -override {{start_row {[expr $start_row - $how_many]}}} {category_id subsubcategory_id subcategory_id how_many}]
}

set how_many_more [expr ${products:rowcount} - $start_row - $how_many + 1]

if { $how_many_more > 0 } {
    set next_url [export_vars -base [ad_conn url] -override {{start_row {[expr $start_row + $how_many]}}} {category_id subsubcategory_id subcategory_id how_many}]

    if { $how_many_more >= $how_many } {
        set how_many_next $how_many
    } else {
        set how_many_next $how_many_more
    }
}

set end [expr $start_row + $how_many - 1]

#==============================
# subcategories

set subcategories ""
if { ![ec_at_bottom_level_p] } {

    db_multirow -extend { url name } -cache_key "ec-${sub}subcategories-${cat_id}" subcategories get_subcategories "see xql" {
        set url [export_vars -base "category-browse-sub${sub}category" {category_id subcategory_id subsubcategory_id}]
        set name [eval "ec_ident \$sub${sub}category_name"] 
    }

}

set the_category_id   $category_id
set the_category_name [eval "ec_ident \$${sub}category_name"]
set category_url "category-browse?category_id=${the_category_id}"
set title "$category_name : $subcategory_name"
set context [list [list $category_url $category_name] $subcategory_name]
set ec_system_owner [ec_system_owner]
db_release_unused_handles
ad_return_template

ad_page_contract {

    Entry page to the ecommerce store.

    @param usca_p
    @param how_many
    @param start_row

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    usca_p:optional
    {how_many:naturalnum {[parameter::get -parameter ProductsToDisplayPerPage -default 10]}}
    {start_row "0"}
}

# see if they're logged in

set user_id [ad_conn user_id]
if { $user_id != 0 } {
    acs_user::get -user_id $user_id -array user_info
    set user_name "$user_info(first_names) $user_info(last_name)"
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

# if for some reason the user id on the session is incorrect, make a new session
# perhaps the old update was an attempt to fix the lose cart on register? anyway
# that is solved correctly now

# TODO: improve session cleanup and add to all pages
if { $user_is_logged_on && $user_session_id ne "0"} {
    if {[db_string check_session_user_id "select user_id from ec_user_sessions where user_session_id = :user_session_id" -default 0] != $user_id} {
        set user_session_id 0 ; # which will force creation of a new session below
    }
}

ec_create_new_session_if_necessary "" cookies_are_not_required

set ec_user_string ""
set register_url "/register?return_url=[ns_urlencode [ec_url]]"

# the base url allows us to switch connections to http from https if currently an https connection
# for saving computing SSL resources only when necessary
set base_url "[ec_insecurelink [ad_conn url]]"

if {[parameter::get -parameter UserClassApproveP] ne ""} {
    set user_class_approved_p_clause "and user_class_approved_p = 't'"
} else {
    set user_class_approved_p_clause ""
}

# must restrict cache per user due to offer pricing
# TODO: actually, it could be by offer code, which would allow less caching
set recommendations_cache_key "ec-index-recommendations-${user_id}"

db_multirow -extend {
                     product_url price_line thumbnail_url thumbnail_width thumbnail_height
                    } -cache_key $recommendations_cache_key recommendations get_produc_recs "see xql" {
                        set price_line [ec_price_line $product_id $user_id $offer_code]
                        set product_url [export_vars -base product -override { product_id $product_id }]

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
                    }

# TODO: templatize and cache product list
set products "<table width=\"100%\">"

set have_how_many_more_p f
set count 0

# find all top-level products (those that are uncategorized)
db_1row get_tl_product_count "
      select count(*) as product_count
      from ec_products_searchable p left outer join ec_user_session_offer_codes o on (p.product_id = o.product_id and user_session_id = :user_session_id)
      where not exists (select 1 
          from ec_category_product_map m
          where p.product_id = m.product_id)"

db_foreach get_tl_products "
    select p.product_id, p.product_name, p.one_line_description, o.offer_code
    from ec_products_searchable p left outer join ec_user_session_offer_codes o on (p.product_id = o.product_id and user_session_id = :user_session_id)
    where not exists (select 1 from ec_category_product_map m where p.product_id = m.product_id)
    order by p.product_name limit :how_many offset :start_row" {

    append products "
          <tr valign=top>
            <td>[expr $count + 1]</td>
            <td colspan=2><a href=\"${base_url}product?product_id=$product_id\"><b>$product_name</b></a></td>
          </tr>
          <tr valign=top>
    	<td></td>
    	<td>$one_line_description</td>
    	<td align=right>[ec_price_line $product_id $user_id $offer_code]</td>
          </tr>"

    incr count
}

if { $product_count > [expr $start_row + (2 * $how_many)] } {
    # we know there are at least how_many more items to display next time
    set have_how_many_more_p t
} else {
    set have_how_many_more_p f
}

if {[string equal $products "<table width=\"100%\">"]} {
    set products ""
} else {
    append products "</table>"
}

set start_row_current $start_row
ns_log Notice $start_row $how_many
if { $start_row_current >= $how_many } {
    set start_row [expr { $start_row_current - $how_many } ]
    set prev_link "<a href=\"${base_url}?[export_vars -url {category_id subcategory_id subsubcategory_id how_many start_row} ]\">Previous $how_many</a>"
} else {
    set prev_link ""
}

if { $have_how_many_more_p eq "t" } {
    set start_row [expr { $start_row_current + $how_many } ]
    set next_link "<a href=\"${base_url}?[export_vars -url {category_id subcategory_id subsubcategory_id how_many start_row}]\">Next $how_many</a>"
} else {
    set number_of_remaining_products [expr { $product_count - $start_row_current - $how_many } ]
    if { $number_of_remaining_products > 0 } {
        set start_row [expr { $start_row_current + $how_many } ]
        set next_link "<a href=\"${base_url}?[export_vars -url category_id subcategory_id subsubcategory_id how_many start_row]\">Next $number_of_remaining_products</a>"
    } else {
        set next_link ""
    }
}

if { [string length $next_link] == 0 || [string length $prev_link] == 0 } {
    set separator ""
} else {
    set separator "|"
}

db_release_unused_handles
ad_return_template

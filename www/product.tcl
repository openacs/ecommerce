#  www/ecommerce/product.tcl
ad_page_contract {
    @param product_id:integer
    @param offer_code:optional
    @param comments_sort_by:optional
    @param usca_p:optional

 display a single product and possibly comments on that
 product or professional reviews
  @author Eve Andersson (eveander@arsdigita.com) 
  @creation-date June 1999
  @cvs-id product.tcl,v 3.1.4.7 2000/09/22 01:37:31 kevin Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    product_id:integer
    offer_code:optional
    comments_sort_by:optional
    usca_p:optional
}


# default to empty string (date)
if { ![info exists comments_sort_by] } {
    set comments_sort_by ""
}

# we don't need them to be logged in, but if they are they might get a lower price
set user_id [ad_verify_and_get_user_id]

# user sessions:
# 1. get user_session_id from cookie
# 2. if user has no session (i.e. user_session_id=0), attempt to set it if it hasn't been
#    attempted before
# 3. if it has been attempted before,
#    (a) if they have no offer_code, then do nothing
#    (b) if they have a offer_code, tell them they need cookies on if they
#        want their offer price
# 4. Log this product_id into the user session

set user_session_id [ec_get_user_session_id]

ec_create_new_session_if_necessary [export_url_vars product_id offer_code] cookies_are_not_required

# valid offer codes must be <= 20 characters, so if it's more than 20 characters, pretend
# it isn't there
if { ![info exists user_session_id] } {
    if { [info exists offer_code] && [string length $offer_code] <= 20 } {
	ad_return_complaint 1 "

        You need to have cookies turned on in order to have
        special offers take effect (we use cookies to remember that you are a
        recipient of this special offer.
        <p>

        Please turn on cookies in your browser, or if you don't wish
        to take advantage of this offer, you can still <a
        href=\"index\">continue shopping at [ec_system_name]</a>
        "
	return
    }
}

if { [string compare $user_session_id "0"] != 0 } {
    db_dml insert_user_session_info "insert into ec_user_session_info (user_session_id, product_id) values (:user_session_id, :product_id)"
}


if { [info exists offer_code] && [string compare $user_session_id "0"] != 0} {
    # insert into or update ec_user_session_offer_codes
    if { [db_string get_offer_code_p "select count(*) from ec_user_session_offer_codes where user_session_id=:user_session_id and product_id=:product_id"] == 0 } {
	db_dml inert_uc_offer_code "insert into ec_user_session_offer_codes (user_session_id, product_id, offer_code) values (:user_session_id, :product_id, :offer_code)"
    } else {
	db_dml update_ec_us_offers "update ec_user_session_offer_codes set offer_code=:offer_code where user_session_id=:user_session_id and product_id=:product_id"
    }
}

if { ![info exists offer_code] && [string compare $user_session_id "0"] != 0} {
    set offer_code [db_string  get_offer_code "select offer_code from ec_user_session_offer_codes where user_session_id=:user_session_id and product_id=:product_id" -default "" ]
}

if { ![info exists offer_code] } {
    set offer_code ""
}

set currency [util_memoize {ad_parameter -package_id [ec_id] Currency ecommerce} [ec_cache_refresh]]
set allow_pre_orders_p [util_memoize {ad_parameter -package_id [ec_id] AllowPreOrdersP ecommerce} [ec_cache_refresh]]

# get all the information from both the products table
# and any custom product fields added by this publisher

# But first...
# This is a major kludge but it is not as bad as the query that follows.

set product_id_temp $product_id

if { [db_0or1row get_ec_product_info "
select *
  from ec_products p, ec_custom_product_field_values v
 where p.product_id = :product_id
   and p.product_id = v.product_id(+)
"]==0} {

    doc_return  200 text/html "[ad_header "Product Not Found"]The product you have requested was not found in the database.  Please contact <a href=\"mailto:[ec_system_owner]\"><address>[ec_system_owner]</address></a> to report the error."
    return
}



if { ![empty_string_p $template_id] } {

    # Template specified by Url

    set template [db_string get_template "
    select template
      from ec_templates
     where template_id=:template_id
    "]

} else {

    # Template specified by Product category

    set template_list [db_list get_template_list "
SELECT template
  FROM ec_templates t, ec_category_template_map ct, ec_category_product_map cp
 WHERE t.template_id = ct.template_id
   AND ct.category_id = cp.category_id
   AND cp.product_id = :product_id"]

    set template [lindex $template_list 0]

    if [empty_string_p $template] {

	# Template specified by... well, just use the default

	set template [db_string get_template_finally "
        select template
          from ec_templates
         where template_id=(select default_template
                              from ec_admin_settings)"]
    }
}


# Finishing up the kludge from a few lines back
set product_id $product_id_temp
#  set category_id [db_string get_product_category "
#  select category_id
#    from ec_category_product_map 
#   where product_id = :product_id
#  "]

db_foreach find_a_good_category "
    select * from 
        (select category_id,
               (select count(*)
                  from ec_subcategories s
                 where s.category_id = m.category_id) subcount,
               (select count(*)
                  from ec_subsubcategories ss
                 where ss.subcategory_id = m.category_id) subsubcount
          from ec_category_product_map m
         where product_id = :product_id
      order by subcount, subsubcount, category_id)
    where rownum = 1
" {
}

db_release_unused_handles
ns_adp_parse -string $template
set r [ns_adp_parse -string $template]
doc_return 200 text/html $r

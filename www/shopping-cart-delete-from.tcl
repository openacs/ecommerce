#  www/ecommerce/shopping-cart-delete-from.tcl
ad_page_contract {
    @param product_id
    @param color_choice
    @param size_choice
    @param style_choice
  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    product_id:integer
    color_choice:optional
    size_choice:optional
    style_choice:optional

}


set user_session_id [ec_get_user_session_id]




set order_id [db_string get_order_id "select order_id from ec_orders where user_session_id=:user_session_id and order_state='in_basket'" -default ""]

if { [empty_string_p $order_id] } {
    # then they probably got here by pushing "Back", so just redirect them
    # into their empty shopping cart
    rp_internal_redirect shopping-cart
    ad_script_abort
}

db_dml delete_item_from_cart "delete from ec_items where order_id=:order_id and product_id=:product_id and color_choice [ec_decode $color_choice "" "is null" "= :color_choice"] and size_choice [ec_decode $size_choice "" "is null" "= :size_choice"] and style_choice [ec_decode $style_choice "" "is null" "= :style_choice"]"
db_release_unused_handles

rp_internal_redirect shopping-cart

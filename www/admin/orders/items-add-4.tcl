# /www/[ec_url_concat [ec_url] /admin]/orders/items-add-4.tcl
ad_page_contract {

  Actually add the items.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id items-add-4.tcl,v 3.3.2.3 2000/08/16 21:19:21 seb Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  item_id:integer,notnull
  order_id:integer,notnull
  product_id:integer,notnull
  color_choice
  size_choice
  style_choice
  price_charged
  price_name
}

ad_require_permission [ad_conn package_id] admin

# double-click protection
if { [db_string doublclick_select "select count(*) from ec_items where item_id=:item_id"] > 0 } {
    ad_returnredirect "one?[export_url_vars order_id]"
    return
}

# must have associated credit card
if [empty_string_p [db_string creditcard_id_select "select creditcard_id from ec_orders where order_id=:order_id"]] {
    ad_return_error "Unable to add items to this order." "
       This order does not have an associated credit card, so new items cannot be added.
       <br>Please create a new order instead."
    return
}

set shipping_method [db_string shipping_method_select "select shipping_method from ec_orders where order_id=:order_id"]

db_transaction {
  db_dml ec_items_insert "insert into ec_items
  (item_id, product_id, color_choice, size_choice, style_choice, order_id, in_cart_date, item_state, price_charged, price_name)
  values
  (:item_id, :product_id, :color_choice, :size_choice, :style_choice, :order_id, sysdate, 'to_be_shipped', :price_charged, :price_name)
  "

  # I calculate the shipping after it's inserted because this procedure goes and checks
  # whether this is the first instance of this product in this order.
  # I know it's non-ideal efficiency-wise, but this procedure (written for the user pages)
  # is already written and it works.

  set shipping_price [ec_shipping_price_for_one_item $item_id $product_id $order_id $shipping_method]

  db_dml ec_items_update "update ec_items set shipping_charged=:shipping_price where item_id=:item_id"
}

ad_returnredirect "one?[export_url_vars order_id]"

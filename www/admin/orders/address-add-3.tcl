# /www/[ec_url_concat [ec_url] /admin]/orders/address-add-3.tcl
ad_page_contract {
  Insert the address.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id address-add-3.tcl,v 3.2.2.4 2000/08/16 16:28:51 seb Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  order_id:integer,notnull
  attn
  line1
  line2
  city
  {usps_abbrev ""}
  {full_state_name ""}
  zip_code
  {country_code "us"}
  phone
  phone_time
}

ad_require_permission [ad_conn package_id] admin

# insert the address into ec_addresses, update the address in ec_orders

db_transaction {
  set address_id [db_string address_id_select "select ec_address_id_sequence.nextval from dual"]
  set user_id [db_string user_id_select "select user_id from ec_orders where order_id=:order_id"]

  db_dml address_insert "insert into ec_addresses
  (address_id, user_id, address_type, attn, line1, line2, city, usps_abbrev, full_state_name, zip_code, country_code, phone, phone_time)
  values
  (:address_id, :user_id, 'shipping', :attn, :line1, :line2, :city, :usps_abbrev, :full_state_name, :zip_code, :country_code, :phone, :phone_time)
  "

  db_dml ec_orders_update "update ec_orders set shipping_address=:address_id where order_id=:order_id"
}

ad_returnredirect "one?[export_url_vars order_id]"

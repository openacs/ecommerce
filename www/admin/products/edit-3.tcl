# /www/[ec_url_concat [ec_url] /admin]/products/edit-3.tcl
ad_page_contract {

  Edit a product.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)

} {

  product_id:integer,notnull
  product_name:notnull
  sku
  one_line_description:html
  detailed_description:html
  color_list
  size_list
  style_list
  email_on_purchase_list
  search_keywords
  url
  price
  no_shipping_avail_p
  present_p
  shipping
  shipping_additional
  weight
  stock_status
  user_class_prices:array,optional
  available_date
  upload_file:optional
  upload_file.tmpfile:optional
  template_id:integer
  category_id_list
  subcategory_id_list
  subsubcategory_id_list
  ec_custom_fields:array,html,optional
}

ad_require_permission [ad_conn package_id] admin

# product_id, product_name, sku, category_id_list, subcategory_id_list, subsubcategory_id_list, one_line_description, detailed_description, color_list, size_list, style_list, email_on_purchase_list, search_keywords, url, price, no_shipping_avail_p, present_p, available_date, shipping, shipping_additional, weight, template_id, stock_status
# the custom product fields may or may not exist
# and price$user_class_id for all the user classes may or may not exist
# (because someone may have added a user class while this product was
# being added)

# we need them to be logged in
set user_id [ad_get_user_id]

set peeraddr [ns_conn peeraddr]

# we have to generate audit information
# First, write as insert
set audit_fields "last_modified, last_modifying_user, modified_ip_address"
# set audit_info "sysdate, :user_id, :peeraddr"
set audit_info [db_map audit_info_sql]

# Or otherwise write as update
#set audit_update "last_modified=sysdate, last_modifying_user=:user_id, modified_ip_address=:peeraddr"
set audit_update [db_map audit_update_sql]

db_transaction {

  # we have to insert or update things in 6 tables: ec_products, ec_custom_product_field_values, 
  # ec_category_product_map, ec_subcategory_product_map, ec_subsubcategory_product_map,
  # ec_product_user_class_prices

  db_dml product_update "
  update ec_products
  set product_name=:product_name,
      sku=:sku,
      one_line_description=:one_line_description,
      detailed_description=:detailed_description,
      color_list=:color_list,
      size_list=:size_list,
      style_list=:style_list,
      email_on_purchase_list=:email_on_purchase_list,
      search_keywords=:search_keywords,
      url=:url,
      price=:price,
      no_shipping_avail_p=:no_shipping_avail_p,
      present_p=:present_p,
      available_date=:available_date,
      shipping=:shipping,
      shipping_additional=:shipping_additional,
      weight=:weight,
      template_id=:template_id,
      stock_status=:stock_status,
      $audit_update
  where product_id=:product_id
  "

  # things to insert or update in ec_custom_product_field_values if they exist
  set custom_columns [db_list custom_columns_select "select field_identifier from ec_custom_product_fields where active_p='t'"]

  set bind_set [ns_set create]
  ns_set put $bind_set product_id $product_id
  ns_set put $bind_set user_id $user_id
  ns_set put $bind_set peeraddr $peeraddr

  if { [db_string num_custom_columns "select count(*) from ec_custom_product_field_values where product_id=:product_id"] == 0 } {
    # then we want to insert, not update
    set custom_columns_to_insert [list product_id]
    set custom_column_values_to_insert [list ":product_id"]
    foreach custom_column $custom_columns {
      if {[info exists ec_custom_fields($custom_column)] } {
	lappend custom_columns_to_insert $custom_column
	lappend custom_column_values_to_insert ":$custom_column"
	ns_set put $bind_set $custom_column $ec_custom_fields($custom_column)
      }
    }
    # DEBUG!!!!
    for {set i 0} {$i < [ns_set size $bind_set]} {incr i} {
      ns_log Notice "\[[ns_set key $bind_set $i]\]: [ns_set value $bind_set $i]"
    }

    db_dml custom_field_insert "
    insert into ec_custom_product_field_values
    ([join $custom_columns_to_insert ", "], $audit_fields)
    values
    ([join $custom_column_values_to_insert ","], $audit_info)
    " -bind $bind_set
  } else {
    set update_list [list]
    foreach custom_column $custom_columns {
      if {[info exists ec_custom_fields($custom_column)] } {
	lappend update_list "$custom_column=:$custom_column"
	ns_set put $bind_set $custom_column $ec_custom_fields($custom_column)
      }
    }

    if {[llength $update_list] > 0 } {
      # DEBUG!!!!
      for {set i 0} {$i < [ns_set size $bind_set]} {incr i} {
	ns_log Notice "\[[ns_set key $bind_set $i]\]: [ns_set value $bind_set $i]"
      }
      db_dml custom_fields_update "update ec_custom_product_field_values set [join $update_list ", "], $audit_update where product_id=:product_id" -bind $bind_set
    }
  }

  # Take care of categories and subcategories and subsubcategories.
  # This is going to leave current values in the map tables, remove 
  # rows no longer valid and add new rows for ids not already there.
  # Because the reference constraints go from categories to subsubcategories
  # first the subsubcategories to categories will be deleted, then
  # new categories down to subsubcategories will be added.

  # Make a list of categories, subcategories, subsubcategories in the database
  set old_category_id_list [db_list old_category_id_list_select "select category_id from ec_category_product_map where product_id=:product_id"]

  set old_subcategory_id_list [db_list old_subcategory_id_list_select "select subcategory_id from ec_subcategory_product_map where product_id=:product_id"]

  set old_subsubcategory_id_list [db_list old_subsubcategory_id_list_select "select subsubcategory_id from ec_subsubcategory_product_map where product_id=:product_id"]

  # Delete subsubcategory maps through category maps

  foreach old_subsubcategory_id $old_subsubcategory_id_list {
    if { [lsearch -exact $subsubcategory_id_list $old_subsubcategory_id] == -1 } {
      # This old subsubcategory id is not in the new list and needs
      # to be deleted
      db_dml subsubcategory_delete "delete from ec_subsubcategory_product_map where product_id=$product_id and subsubcategory_id=:old_subsubcategory_id"

      # audit
      ec_audit_delete_row [list $old_subsubcategory_id $product_id] [list subsubcategory_id product_id] ec_subsubcat_prod_map_audit
    }
  }

  foreach old_subcategory_id $old_subcategory_id_list {
    if { [lsearch -exact $subcategory_id_list $old_subcategory_id] == -1 } {
      # This old subcategory id is not in the new list and needs
      # to be deleted
      db_dml subcategory_delete "delete from ec_subcategory_product_map where product_id=:product_id and subcategory_id=:old_subcategory_id"

      # audit
      ec_audit_delete_row [list $old_subcategory_id $product_id] [list subcategory_id product_id] ec_subcat_prod_map_audit
    }
  }

  foreach old_category_id $old_category_id_list {
    if { [lsearch -exact $category_id_list $old_category_id] == -1 } {
      # This old category id is not in the new list and needs
      # to be deleted
      db_dml category_delete "delete from ec_category_product_map where product_id=:product_id and category_id=:old_category_id"

      # audit
      ec_audit_delete_row [list $old_category_id $product_id] [list category_id product_id] ec_category_product_map_audit
    }
  }

  # Now add categorization maps

  foreach new_category_id $category_id_list {
    if { [lsearch -exact $old_category_id_list $new_category_id] == -1 } {
      # The new category id is not an existing category mapping
      # so add it.
      db_dml category_insert "insert into ec_category_product_map (product_id, category_id, $audit_fields) values (:product_id, :new_category_id, $audit_info)"
    }
  }

  foreach new_subcategory_id $subcategory_id_list {
    if { [lsearch -exact $old_subcategory_id_list $new_subcategory_id] == -1 } {
      # The new subcategory id is not an existing subcategory mapping
      # so add it.
      db_dml subcategory_insert "insert into ec_subcategory_product_map (product_id, subcategory_id, $audit_fields) values (:product_id, :new_subcategory_id, $audit_info)"
    }
  }

  foreach new_subsubcategory_id $subsubcategory_id_list {
    if { [lsearch -exact $old_subsubcategory_id_list $new_subsubcategory_id] == -1 } {
      # The new subsubcategory id is not an existing subsubcategory mapping
      # so add it.
      db_dml subsubcategory_insert "insert into ec_subsubcategory_product_map (product_id, subsubcategory_id, $audit_fields) values (:product_id, :new_subsubcategory_id, $audit_info)"
    }
  }

  # Take care of special prices for user classes
  # First get a list of old user_class_id values and a list of all 
  # user_class_id values.
  # Then delete a user_class_price if its ID does not exist or value is empty.
  # Last go through all user_class_id values and add the user_class_price
  # if it is not in the old user_class_id_list
  set all_user_class_id_list [db_list all_user_class_id_list_select "select user_class_id from ec_user_classes"]

  set old_user_class_id_list [list]
  set old_user_class_price_list [list]
  db_foreach user_class_select "select user_class_id, price from ec_product_user_class_prices where product_id=$product_id" {
    lappend old_user_class_id_list $user_class_id
    lappend old_user_class_price_list $price
  }

  # Counter is used to find the corresponding user_class_price for the current
  # user_class_id
  set counter 0
  foreach user_class_id $old_user_class_id_list {
    if { ![info exists user_class_prices($user_class_id)] || [empty_string_p [set user_class_prices($user_class_id)]] } {
      # This old user_class_id does not have a value, so delete it
      db_dml user_class_price_delete "delete from ec_product_user_class_prices where user_class_id = :user_class_id"

      # audit
      ec_audit_delete_row [list $user_class_id [lindex $old_user_class_price_list $counter] $product_id] [list user_class_id price product_id] ec_product_u_c_prices_audit
    }
    incr counter
  }

  # Add new values
  foreach user_class_id $all_user_class_id_list {
    if { [info exists user_class_prices($user_class_id)] } {
      # This user_class_id exists and must either be inserted
      # or updated if its value has changed.
      set user_class_price $user_class_prices($user_class_id)

      set index [lsearch -exact $old_user_class_id_list $user_class_id]
      if { $index == -1 } {
	# This user_class_id exists and is not in the 
	db_dml user_class_price_insert "insert into ec_product_user_class_prices (product_id, user_class_id, price, $audit_fields) values (:product_id, :user_class_id, :user_class_price, $audit_info)"
      } else {
	# Check if user_class_price has changed
	if { $user_class_prices($user_class_id) != [lindex $old_user_class_price_list $index] } {
	  db_dml user_class_price_update "update ec_product_user_class_prices set price=:user_class_price, $audit_update where user_class_id = :user_class_id and product_id = :product_id"
	}
      }
    }
  }
}

ad_returnredirect "one?[export_url_vars product_id]"

# /www/[ec_url_concat [ec_url] /admin]/products/add-4.tcl
ad_page_contract {

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id add-4.tcl,v 3.3.6.4 2000/08/21 21:20:33 tzumainn Exp
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
  dirname
  template_id:integer
  category_id_list
  subcategory_id_list
  subsubcategory_id_list
  ec_custom_fields:array,optional
}
# set_the_usual_form_variables

ad_require_permission [ad_conn package_id] admin

# product_id, product_name, sku, category_id_list, subcategory_id_list, subsubcategory_id_list, one_line_description, detailed_description, color_list, size_list, style_list, email_on_purchase_list, search_keywords, url, price, no_shipping_avail_p, present_p, available_date, shipping, shipping_additional, weight, template_id, dirname, stock_status
# the custom product fields may or may not exist
# and price$user_class_id for all the user classes may or may not exist
# (because someone may have added a user class while this product was
# being added)

# we need them to be logged in
ad_maybe_redirect_for_registration
set user_id [ad_get_user_id]
set peeraddr [ns_conn peeraddr]

# make sure this product isn't already in the database (implying they pushed reload)
if { [db_string doubleclick_select "select count(*) from ec_products where product_id=:product_id"] > 0 } {
    ad_returnredirect "one?[export_url_vars product_id]"
    return
}

set user_class_id_list [db_list user_class_select "select user_class_id from ec_user_classes"]

# grab package_id as context_id
set context_id [ad_conn package_id]

db_transaction {

  # we have to insert things into 6 tables: ec_products, ec_custom_product_field_values, 
  # ec_category_product_map, ec_subcategory_product_map, ec_subsubcategory_product_map,
  # ec_product_user_class_prices
  # wtem@olywa.net, 2001-03-25
  # and now acs_objects via the ec_product.new function

  # we have to generate audit information
  set audit_fields "last_modified, last_modifying_user, modified_ip_address"

  ### find out which database we are using
  # for postgresql we need to run two queries for the insert
  # for oracle, we only need to run the product_insert query
  set db_type [db_type]
  # db_map this
  # set audit_info "sysdate, :user_id, :peeraddr"
  set audit_info [db_map audit_info_sql] 

  if [string match $db_type "oracle"] {
    db_exec_plsql product_insert {
	begin
	:1 := ec_product.new(product_id => :product_id,
	object_type => 'ec_product',
	creation_date => sysdate,
	creation_user => :user_id,
	creation_ip => :peeraddr,
	context_id => :context_id,
	product_name => :product_name, 
	price => :price, 
	sku => :sku,
	one_line_description => :one_line_description, 
	detailed_description => :detailed_description, 
	search_keywords => :search_keywords, 
	present_p => :present_p, 
	stock_status => :stock_status,
	dirname => :dirname, 
	available_date => to_date(:available_date, 'YYYY-MM-DD'), 
	color_list => :color_list, 
	size_list => :size_list, 
	style_list => :style_list, 
	email_on_purchase_list => :email_on_purchase_list, 
	url => :url,
	no_shipping_avail_p => :no_shipping_avail_p, 
	shipping => :shipping,
	shipping_additional => :shipping_additional, 
	weight => :weight, 
	active_p => 't',
	template_id => :template_id
	);
	end;
    }
  } elseif [string match $db_type "postgresql"] {
    set product_id [db_exec_plsql product_insert {
	select ec_product__new(
        :product_id,
        :user_id,
        :context_id,
        :product_name,
        :price,
        :sku,
        :one_line_description,
        :detailed_description,
        :search_keywords,
        :present_p,
        :stock_status,
        :dirname,
        to_date(:available_date, 'YYYY-MM-DD'),
        :color_list,
        :size_list,
        :peeraddr
        );
    }]

    db_dml product_update {
	update ec_products set style_list = :style_list,
        email_on_purchase_list = :email_on_purchase_list,
        url = :url,
        no_shipping_avail_p = :no_shipping_avail_p,
        shipping = :shipping,
        shipping_additional = :shipping_additional,
        weight = :weight,
        active_p = 't',
        template_id = :template_id
        where product_id = :product_id;
    }
  }

#    db_dml product_insert "
#    insert into ec_products
#    (product_id, product_name, sku, one_line_description, detailed_description, color_list, size_list, style_list, email_on_purchase_list, search_keywords, url, price, no_shipping_avail_p, present_p, available_date, shipping, shipping_additional, weight, template_id, dirname, active_p, stock_status, $audit_fields)
#    values
#    (:product_id, :product_name, :sku, :one_line_description, :detailed_description, :color_list, :size_list, :style_list, :email_on_purchase_list, :search_keywords, :url, :price, :no_shipping_avail_p, :present_p, to_date(:available_date, 'YYYY-MM-DD'), :shipping, :shipping_additional, :weight, :template_id, :dirname, 't', :stock_status, $audit_info)
#    "

  # things to insert into ec_custom_product_field_values if they exist
  set custom_columns_to_insert [list product_id]
  set custom_column_values_to_insert [list ":product_id"]
  set bind_set [ns_set create]
  ns_set put $bind_set product_id $product_id
  ns_set put $bind_set user_id $user_id
  ns_set put $bind_set peeraddr $peeraddr
  db_foreach custom_columns_select {
    select field_identifier
    from ec_custom_product_fields
    where active_p='t'
  } {
    if {[info exists ec_custom_fields($field_identifier)] } {
      lappend custom_columns_to_insert $field_identifier
      lappend custom_column_values_to_insert ":$field_identifier"
      ns_set put $bind_set $field_identifier $ec_custom_fields($field_identifier)
    }
  }

  db_dml custom_fields_insert "
  insert into ec_custom_product_field_values
  ([join $custom_columns_to_insert ", "], $audit_fields)
  values
  ([join $custom_column_values_to_insert ","], $audit_info)
  " -bind $bind_set

  # Take care of categories and subcategories and subsubcategories
  foreach category_id $category_id_list {
    db_dml category_insert "
    insert into ec_category_product_map (product_id, category_id, $audit_fields)
    values
    (:product_id, :category_id, $audit_info)
    "
  }

  foreach subcategory_id $subcategory_id_list {
    db_dml subcategory_insert "
    insert into ec_subcategory_product_map (
     product_id, subcategory_id, $audit_fields) values (
     :product_id, :subcategory_id, $audit_info)"
  }

  foreach subsubcategory_id $subsubcategory_id_list {
    db_dml subsubcategory_insert "
    insert into ec_subsubcategory_product_map (
     product_id, subsubcategory_id, $audit_fields) values (
     :product_id, :subsubcategory_id, $audit_info)"
  }

  # Take care of special prices for user classes
  foreach user_class_id $user_class_id_list {
    if { [info exists user_class_prices($user_class_id)] } {
      set uc_price $user_class_prices($user_class_id)
      db_dml user_class_insert "
      insert into ec_product_user_class_prices (
      product_id, user_class_id, price, $audit_fields) values (
      :product_id, :user_class_id, :uc_price, $audit_info)"
    }
  }
}

ad_returnredirect "one?[export_url_vars product_id]"

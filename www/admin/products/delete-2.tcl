# /www/[ec_url_concat [ec_url] /admin]/products/delete-2.tcl
ad_page_contract {
  Delete a product.

  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  product_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

# we need them to be logged in
set user_id [ad_get_user_id]

set product_name [ec_product_name $product_id]

# cannot delete if there is an order which has this product, i.e. if
# this product exists in:
# ec_items

# have to delete from:
# ec_offers
# ec_custom_product_field_values
# ec_subsubcategory_product_map
# ec_subcategory_product_map
# ec_category_product_map
# ec_product_reviews
# ec_product_comments
# ec_product_links
# ec_product_user_class_prices
# ec_product_series_map
# ec_products

# (2000-08-20 Seb) ec_sale_prices



if { [db_string order_count_select "select count(*) from ec_items where product_id=:product_id"] > 0 } {
    doc_return  200 text/html "[ad_admin_header "Sorry"]\nSorry, you cannot delete a product for which an order has already been made.  Instead, you can <a href=\"toggle-active-p?[export_url_vars product_id product_name]&active_p=f\">Mark It Inactive</a>, which will make it no longer show up in the consumer pages."
    return
}

db_transaction {

  # 1. Offers
  set offer_list [db_list offer_list_select "select offer_id from ec_offers where product_id=:product_id"]

  db_dml offers_delete "delete from ec_offers where product_id=:product_id"

  # audit
  foreach offer_id $offer_list {
    ec_audit_delete_row [list $offer_id $product_id] [list offer_id product_id] ec_offers_audit
  }

  # 2. Custom Product Field Values
  db_dml custom_product_fields_delete "delete from ec_custom_product_field_values where product_id=:product_id"
  ec_audit_delete_row [list $product_id] [list product_id] ec_custom_p_field_values_audit

  # 3. Subsubcategory Product map
  set subsubcategory_list [db_list subsubcategory_list_select "select subsubcategory_id from ec_subsubcategory_product_map where product_id=:product_id"]

  db_dml subsubcategory_delete "delete from ec_subsubcategory_product_map where product_id=:product_id"

  # audit
  foreach subsubcategory_id $subsubcategory_list {
    ec_audit_delete_row [list $subsubcategory_id $product_id] [list subsubcategory_id product_id] ec_subsubcat_prod_map_audit
  }

  # 4. Subcategory Product map
  set subcategory_list [db_list subcategory_list_select "select subcategory_id from ec_subcategory_product_map where product_id=:product_id"]

  db_dml subcategory_delete "delete from ec_subcategory_product_map where product_id=:product_id"

  # audit
  foreach subcategory_id $subcategory_list {
    ec_audit_delete_row [list $subcategory_id $product_id] [list subcategory_id product_id] ec_subcat_prod_map_audit
  }

  # 5. Category Product map
  set category_list [db_list category_list_select "select category_id from ec_category_product_map where product_id=:product_id"]

  db_dml category_delete "delete from ec_category_product_map where product_id=:product_id"

  # audit
  foreach category_id $category_list {
    ec_audit_delete_row [list $category_id $product_id] [list category_id product_id] ec_category_product_map_audit
  }

  # 6. Product Reviews
  set review_list [db_list review_list_select "select review_id from ec_product_reviews where product_id=:product_id"]

  db_dml review_delete "delete from ec_product_reviews where product_id=:product_id"

  # audit
  foreach review_id $review_list {
    ec_audit_delete_row [list $review_id $product_id] [list review_id product_id] ec_product_reviews_audit
  }

  # 7. Product Comments
  db_dml product_comments_delete "delete from ec_product_comments where product_id=:product_id"

  # comments aren't audited

  # 8. Product Relationship Links
  set product_a_list [db_list product_a_list_select "select product_a from ec_product_links where product_b=:product_id"]
  set product_b_list [db_list product_b_list_select "select product_b from ec_product_links where product_a=:product_id"]

  db_dml links_delete "delete from ec_product_links where product_a=:product_id or product_b=:product_id"

  # audit
  foreach product_a $product_a_list {
    ec_audit_delete_row [list $product_a $product_id] [list product_a product_id] ec_product_links_audit
  }
  foreach product_b $product_b_list {
    ec_audit_delete_row [list $product_b $product_id] [list product_b product_id] ec_product_links_audit
  }

  # 9. User Class
  set user_class_id_list [list]
  set user_class_price_list [list]
  db_foreach user_class_select "select user_class_id, price from ec_product_user_class_prices where product_id=:product_id" {
      if { [empty_string_p $price] } { 
	  set price [db_null]
      }
      lappend user_class_id_list $user_class_id
      lappend user_class_price_list $price
  }
  db_dml delete_from_session_info "delete from ec_user_session_info where product_id=:product_id"


  db_dml user_class_prices_delete "delete from ec_product_user_class_prices where product_id=:product_id"

  # audit
  set counter 0
  foreach user_class_id $user_class_id_list {
    ec_audit_delete_row [list $user_class_id [lindex $user_class_price_list $counter] $product_id] [list user_class_id price product_id] ec_product_u_c_prices_audit
    incr counter
  }

  # 10. Product Series map
  set series_id_list [db_list series_id_list_select "select series_id from ec_product_series_map where component_id=:product_id"]
  set component_id_list [db_list component_id_list_select "select component_id from ec_product_series_map where series_id=:product_id"]

  db_dml series_delete "delete from ec_product_series_map where series_id=:product_id or component_id=:product_id"

  # audit
  foreach series_id $series_id_list {
    ec_audit_delete_row [list $series_id $product_id] [list series_id component_id] ec_product_series_map_audit
  }
  foreach component_id $component_id_list {
    ec_audit_delete_row [list $product_id $component_id] [list series_id component_id] ec_product_series_map_audit
  }

  # 11. ec_sale_prices
  set sale_price_list [db_list sale_price_list_select "select sale_price_id from ec_sale_prices where product_id=:product_id"]

  db_dml sale_price_delete "delete from ec_sale_prices where product_id=:product_id"

  # audit
  foreach sale_price_id $sale_price_list {
    ec_audit_delete_row [list $sale_price_id] [list sale_price_id] ec_sale_prices_audit
  }

  # 12. Products
  # wtem@olywa.net, 2001-03-25
  # replaced straight delete statement
  # with ec_product.delete pl/sql procedure
  db_exec_plsql product_delete {
      begin
      ec_product.delete(:product_id);
      end;
  }

  # audit
  ec_audit_delete_row [list $product_id] [list product_id] ec_products_audit

}

ad_returnredirect "index"

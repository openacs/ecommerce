# /www/[ec_url_concat [ec_url] /admin]/products/add-3.tcl
ad_page_contract {

  Add a product.

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
  linked_thumbnail:allhtml
  dirname
  template_id:integer
  category_id_list
  subcategory_id_list
  subsubcategory_id_list
  ec_custom_fields:array,optional
}

ad_require_permission [ad_conn package_id] admin

# set_the_usual_form_variables
# product_name, sku, one_line_description, color_list, size_list, style_list,
# email_on_purchase_list, detailed_description, search_keywords, url, price, 
# no_shipping_avail_p, present_p, available_date, shipping, shipping_additional, weight,
# product_id, linked_thumbnail, dirname, stock_status, template_id
# and all active custom fields (except ones that are boolean and weren't filled in)
# and price$user_class_id for all the user classes
# category_id_list, subcategory_id_list, subsubcategory_id_list
set title "Confirm New Product"
set context [list $title]


set currency [parameter::get -package_id [ec_id] -parameter Currency]
set multiple_retailers_p [parameter::get -package_id [ec_id] -parameter MultipleRetailersPerProductP -default f]

set categorization_html [ec_category_subcategory_and_subsubcategory_display $category_id_list $subcategory_id_list $subsubcategory_id_list]

if { !$multiple_retailers_p } {
    if { ![empty_string_p $stock_status] } {
        set stock_status_html [util_memoize "ad_parameter -package_id [ec_id] \"StockMessage[string toupper $stock_status]\"" [ec_cache_refresh]]
    } else {
        set stock_status_html [ec_message_if_null $stock_status]
    }
    set price_html [ec_message_if_null [ec_pretty_price $price $currency]]
    set shipping_html [ec_message_if_null [ec_pretty_price $shipping $currency]]
    set shipping_additional_html [ec_message_if_null [ec_pretty_price $shipping_additional $currency]]
}

set user_class_select_html ""
db_foreach user_class_select "select user_class_id, user_class_name from ec_user_classes order by user_class_name" {
    if { [info exists user_class_prices($user_class_id)] } {
        append user_class_select_html "
      <tr><td align=\"right\">${user_class_name} Price: </td><td>
      [ec_message_if_null [ec_pretty_price [set user_class_prices($user_class_id)] $currency]]
      </td></tr>"
    }
}
set one_line_description_html [ec_message_if_null $one_line_description]

set detailed_description_html [ec_display_as_html [ec_message_if_null $detailed_description]]
set search_keywords_html [ec_message_if_null $search_keywords]
set color_list_html [ec_message_if_null $color_list]
set size_list_html [ec_message_if_null $size_list]
set style_list_html [ec_message_if_null $style_list]
set email_on_purchase_list_html [ec_message_if_null $email_on_purchase_list]
set url_html [ec_message_if_null $url]
set no_shipping_avail_p_html [ec_message_if_null [ec_PrettyBoolean [ec_decode $no_shipping_avail_p "t" "f" "f" "t"]]]
set present_p_html [ec_message_if_null [ec_PrettyBoolean $present_p]]
    
set weight_html "[ec_message_if_null $weight] [ec_decode $weight "" "" [parameter::get -package_id [ec_id] -parameter WeightUnits -default lbs]]"

set custom_product_fields_select_html ""
db_foreach custom_fields_select {
    select field_identifier, field_name, column_type
    from ec_custom_product_fields
    where active_p = 't'
} {
    if { [info exists ec_custom_fields($field_identifier)] } {
        append custom_product_fields_select_html "<tr><td align=\"right\">$field_name</td><td>"
        if { $column_type == "char(1)" } {
            append custom_product_fields_select_html "[ec_message_if_null [ec_PrettyBoolean $ec_custom_fields($field_identifier)]]\n"
        } elseif { $column_type == "date" } {
            append custom_product_fields_select_html "[ec_message_if_null [util_AnsiDatetoPrettyDate $ec_custom_fields($field_identifier)]]\n"
        } else {
            append custom_product_fields_select_html "[ec_display_as_html [ec_message_if_null $ec_custom_fields($field_identifier)]]\n"
        }
        append custom_product_fields_select_html "</td></tr>"
    }
}

set template_html [ec_message_if_null [db_string template_name_select "select template_name from ec_templates where template_id=:template_id" -default "" ]]
set export_form_vars_html [export_form_vars product_name sku category_id_list subcategory_id_list subsubcategory_id_list one_line_description detailed_description color_list size_list style_list email_on_purchase_list search_keywords url price no_shipping_avail_p present_p available_date shipping shipping_additional weight template_id product_id dirname stock_status]

# also need to export custom field values
set custom_fields_select_html ""
db_foreach custom_fields_select {
    select field_identifier 
    from ec_custom_product_fields 
    where active_p='t'
} {
    if { [info exists ec_custom_fields($field_identifier)] } {
        append custom_fields_select_html "<input type=hidden name=\"ec_custom_fields.$field_identifier\" value=\"[ad_quotehtml $ec_custom_fields($field_identifier)]\">\n"
    }
}
set user_class_select_html ""
foreach user_class_id [db_list user_class_select "select user_class_id from ec_user_classes"] {
    append user_class_select_html "<input type=hidden name=\"user_class_prices.$user_class_id\" value=\"$user_class_prices($user_class_id)\">"
}


# /www/[ec_url_concat [ec_url] /admin]/products/add-3.tcl
ad_page_contract {

  Add a product.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id add-3.tcl,v 3.4.2.6 2000/08/21 21:20:10 tzumainn Exp
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

doc_body_append "[ad_admin_header "Confirm New Product"]

<h2>Confirm New Product</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Products"] "Add Product"]

<hr>
<h3>Please confirm that the information below is correct:</h3>
"
set currency [util_memoize {ad_parameter -package_id [ec_id] Currency ecommerce} [ec_cache_refresh]]
set multiple_retailers_p [util_memoize {ad_parameter -package_id [ec_id] MultipleRetailersPerProductP ecommerce} [ec_cache_refresh]]

doc_body_append "<form method=post action=add-4>
<center>
<input type=submit value=\"Confirm\">
</center>
<blockquote>
$linked_thumbnail
<table noborder>
<tr>
<td>
Product Name:
</td>
<td>
$product_name
</td>
</tr>
<tr>
<td>
SKU:
</td>
<td>
$sku
</td>
</tr>
<tr>
<td>
Categorization:
</td>
<td>
[ec_category_subcategory_and_subsubcategory_display $category_id_list $subcategory_id_list $subsubcategory_id_list]
</td>
</tr>
"
if { !$multiple_retailers_p } {
    doc_body_append "<tr>
    <td>
    Stock Status:
    </td>
    <td>
    "
    if { ![empty_string_p $stock_status] } {
	doc_body_append [util_memoize "ad_parameter -package_id [ec_id] \"StockMessage[string toupper $stock_status]\"" [ec_cache_refresh]]
    } else {
	doc_body_append [ec_message_if_null $stock_status]
    }

    doc_body_append "</td>
    </tr>
    "
}
doc_body_append "<tr>
<td>
One-Line Description:
</td>
<td>
[ec_message_if_null $one_line_description]
</td>
</tr>
<tr>
<td>
Additional Descriptive Text:
</td>
<td>
[ec_display_as_html [ec_message_if_null $detailed_description]]
</td>
</tr>
<tr>
<td>
Search Keywords:
</td>
<td>
[ec_message_if_null $search_keywords]
</td>
</tr>
<tr>
<td>
Color Choices:
</td>
<td>
[ec_message_if_null $color_list]
</td>
</tr>
<tr>
<td>
Size Choices:
</td>
<td>
[ec_message_if_null $size_list]
</td>
</tr>
<tr>
<td>
Style Choices:
</td>
<td>
[ec_message_if_null $style_list]
</td>
</tr>
<tr>
<td>
Email On Purchase:
</td>
<td>
[ec_message_if_null $email_on_purchase_list]
</td>
</tr>
<tr>
<td>
URL:
</td>
<td>
[ec_message_if_null $url]
</td>
</tr>
"
if { !$multiple_retailers_p } {
    doc_body_append "<tr>
    <td>
    Regular Price:
    </td>
    <td>
    [ec_message_if_null [ec_pretty_price $price $currency]]
    </td>
    </tr>
    "
}
doc_body_append "<tr>
<td>
Is this product shippable?
</td>
<td>
[ec_message_if_null [ec_PrettyBoolean [ec_decode $no_shipping_avail_p "t" "f" "f" "t"]]]
</td>
</tr>
<tr>
<td>
Display this product when user does a search?
</td>
<td>
[ec_message_if_null [ec_PrettyBoolean $present_p]]
</td>
</tr>
"
if { !$multiple_retailers_p } {
    doc_body_append "<tr>
    <td>
    Shipping Price
    </td>
    <td>
    [ec_message_if_null [ec_pretty_price $shipping $currency]]
    </td>
    </tr>
    <tr>
    <td>
    Shipping - Additional
    </td>
    <td>
    [ec_message_if_null [ec_pretty_price $shipping_additional $currency]]
    </td>
    </tr>
    "
}
doc_body_append "<tr>
<td>
Weight
</td>
<td>
[ec_message_if_null $weight] [ec_decode $weight "" "" [util_memoize {ad_parameter -package_id [ec_id] WeightUnits ecommerce} [ec_cache_refresh]]]
</td>
</tr>
"
if { !$multiple_retailers_p } {
  db_foreach user_class_select "select user_class_id, user_class_name from ec_user_classes order by user_class_name" {
    if { [info exists user_class_prices($user_class_id)] } {
      doc_body_append "
      <tr>
      <td>
      $user_class_name Price:
      </td>
      <td>
      [ec_message_if_null [ec_pretty_price [set user_class_prices($user_class_id)] $currency]]
      </td>
      </tr>
      "
    }
  }
}

db_foreach custom_fields_select {
  select field_identifier, field_name, column_type
  from ec_custom_product_fields
  where active_p = 't'
} {
  if { [info exists ec_custom_fields($field_identifier)] } {
    doc_body_append "
    <tr>
    <td>
    $field_name
    </td>
    <td>
    "
    if { $column_type == "char(1)" } {
      doc_body_append "[ec_message_if_null [ec_PrettyBoolean $ec_custom_fields($field_identifier)]]\n"
    } elseif { $column_type == "date" } {
      doc_body_append "[ec_message_if_null [util_AnsiDatetoPrettyDate $ec_custom_fields($field_identifier)]]\n"
    } else {
      doc_body_append "[ec_display_as_html [ec_message_if_null $ec_custom_fields($field_identifier)]]\n"
    }
    doc_body_append "</td>
    </tr>
    "
  }
}

doc_body_append "<tr>
<td>
Template
</td>
<td>
[ec_message_if_null [db_string template_name_select "select template_name from ec_templates where template_id=:template_id" -default "" ]]
</td>
</tr>
</table>
</blockquote>
<p>
[export_form_vars product_name sku category_id_list subcategory_id_list subsubcategory_id_list one_line_description detailed_description color_list size_list style_list email_on_purchase_list search_keywords url price no_shipping_avail_p present_p available_date shipping shipping_additional weight template_id product_id dirname stock_status]
"

# also need to export custom field values
db_foreach custom_fields_select {
  select field_identifier 
  from ec_custom_product_fields 
  where active_p='t'
} {
    if { [info exists ec_custom_fields($field_identifier)] } {
      doc_body_append "<input type=hidden name=\"ec_custom_fields.$field_identifier\" value=\"[ad_quotehtml $ec_custom_fields($field_identifier)]\">\n"
    }
}

foreach user_class_id [db_list user_class_select "select user_class_id from ec_user_classes"] {
  doc_body_append "<input type=hidden name=\"user_class_prices.$user_class_id\" value=\"$user_class_prices($user_class_id)\">"
}

doc_body_append "<center>
<input type=submit value=\"Confirm\">
</center>
</form>

[ad_admin_footer]
"

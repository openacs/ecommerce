# /www/[ec_url_concat [ec_url] /admin]/products/edit.tcl
ad_page_contract {

  Form for the user to edit the main fields in the ec_product table
  plus custom fields.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date June 1999
  @cvs-id edit.tcl,v 3.4.2.5 2000/08/20 22:38:41 seb Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)

} {

  product_id:integer,notnull

}

ad_require_permission [ad_conn package_id] admin

set product_name [ec_product_name $product_id]

doc_body_append "[ad_admin_header "Edit $product_name"]

<h2>Edit $product_name</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Products"] [list "one?[export_url_vars product_id]" "One"] "Edit"]

<hr>

All fields are optional except Product Name.
<p>
"
set multiple_retailers_p [ad_parameter -package_id [ec_id] MultipleRetailersPerProductP ecommerce]

db_1row product_select "
select product_id, sku, product_name, 
to_char(creation_date, 'YYYY-MM-DD') as creation_date, one_line_description, 
detailed_description, search_keywords, price, no_shipping_avail_p, shipping, 
shipping_additional, weight, dirname, present_p, active_p, 
to_char(available_date, 'YYYY-MM-DD') as available_date, announcements, 
to_char(announcements_expire, 'YYYY-MM-DD') as announcements_expire, url, 
template_id, stock_status, color_list, size_list, style_list, 
email_on_purchase_list, to_char(last_modified, 'YYYY-MM-DD') as last_modified, 
last_modifying_user, modified_ip_address
from ec_products where product_id=:product_id
"

doc_body_append "<form enctype=multipart/form-data method=post action=edit-2>
[export_form_vars product_id]
<table>
<tr>
<td>Product Name</td>
<td colspan=2><input type=text name=product_name size=30 value=\"[ad_quotehtml $product_name]\"></td>
</tr>
<tr>
<td>SKU</td>
<td><input type=text name=sku size=10 value=\"[ad_quotehtml $sku]\"></td>
<td>It's not necessary to include a SKU because the system generates its own
internal product_id to uniquely distinguish products.</td>
</tr>
"

# have to deal with category widget

set category_list [db_list category_list_select "select category_id from ec_category_product_map where product_id=:product_id"]

set subcategory_list [db_list subcategory_list_select "select subcategory_id from ec_subcategory_product_map where product_id=:product_id"]

set subsubcategory_list [db_list subsubcategory_list_select "select subsubcategory_id from ec_subsubcategory_product_map where product_id=:product_id"]

set categorization_default [ec_determine_categorization_widget_defaults $category_list $subcategory_list $subsubcategory_list]

doc_body_append "<tr>
<td>Product Category</td>
<td>[ec_category_widget t $categorization_default]</td>
<td>Choose as many categories as you like.  The product will
be displayed on the web site in each of the categories you select.</td>
</tr>
"
if { !$multiple_retailers_p } {
    doc_body_append "<tr>
    <td>Stock Status</td>
    <td colspan=2>[ec_stock_status_widget $stock_status]</td>
    </tr>
    "
} else {
    doc_body_append "[export_form_vars stock_status]\n"
}
doc_body_append "<tr>
<td>One-Line Description</td>
<td colspan=2><input type=text name=one_line_description size=60 value=\"[ad_quotehtml $one_line_description]\"></td>
</tr>
<tr>
<td>Additional Descriptive Text</td>
<td colspan=2><textarea wrap rows=6 cols=60 name=detailed_description>$detailed_description</textarea></td>
</tr>
<tr>
<td>Search Keywords</td>
<td colspan=2><textarea wrap rows=2 cols=60 name=search_keywords>$search_keywords</textarea></td>
</tr>
<tr>
<td>Picture</td>
<td><input type=file size=10 name=upload_file>"

set thumbnail [ec_linked_thumbnail_if_it_exists $dirname f]
if { ![empty_string_p $thumbnail] } {
    doc_body_append "<br>Your current picture is:<br>$thumbnail"
}

doc_body_append "</td>
<td>This picture (.gif or .jpg format) can be as large as you like.  A thumbnail will be automatically generated.  Note that file uploading doesn't work with Internet Explorer 3.0.</td>
</tr>
<tr>
<td>Color Choices</td>
<td><input type=text name=color_list size=40 value=\"[ad_quotehtml $color_list]\"></td>
<td>This should be a comma-separated list of colors the user is allowed to choose from
when ordering.  If there are no choices, leave this blank.</td>
</tr>
<tr>
<td>Size Choices</td>
<td><input type=text name=size_list size=40 value=\"[ad_quotehtml $size_list]\"></td>
<td>This should be a comma-separated list of sizes the user is allowed to choose from
when ordering.  If there are no choices, leave this blank.</td>
</tr>
<tr>
<td>Style Choices</td>
<td><input type=text name=style_list size=40 value=\"[ad_quotehtml $style_list]\"></td>
<td>This should be a comma-separated list of styles the user is allowed to choose from
when ordering.  If there are no choices, leave this blank.</td>
</tr>
<tr>
<td>Email on Purchase</td>
<td><input type=text name=email_on_purchase_list size=40 value=\"[ad_quotehtml $email_on_purchase_list]\"></td>
<td>This should be a comma-separated list of recipients to notify when a purchase is made. If you do not wish email to be sent, leave this blank.</td>
</tr>
<tr>
<td>URL where the consumer can get more info on the product</td>
"
if { [empty_string_p $url] } {
    set url "http://"
}
doc_body_append "<td colspan=2><input type=text name=url size=50 value=\"[ad_quotehtml $url]\"></td>
</tr>
"
if { !$multiple_retailers_p } {
    doc_body_append "<tr>
    <td>Regular Price</td>
    <td><input type=text size=6 name=price value=\"$price\"></td>
    <td>All prices are in [ad_parameter -package_id [ec_id] Currency ecommerce].  The price should
    be written as a decimal number (no special characters like \$).
    </tr>
    "
} else {
    doc_body_append "[export_form_vars price]\n"
}
doc_body_append "<tr>
<td>Is this product shippable?</td>
<td><input type=radio name=no_shipping_avail_p value=\"f\""

if { $no_shipping_avail_p == "f" } {
    doc_body_append " checked "
}

doc_body_append ">Yes
&nbsp;&nbsp;
<input type=radio name=no_shipping_avail_p value=\"t\""

if { $no_shipping_avail_p == "t" } {
    doc_body_append " checked "
}

doc_body_append ">No
</td>
<td>You might choose \"No\" if this product is actually a service.</td>
</tr>
<tr>
<td>Should this product be displayed when the user does a search?</td>
<td><input type=radio name=present_p value=\"t\""

if { $present_p == "t" } {
    doc_body_append " checked "
}

doc_body_append ">Yes
&nbsp;&nbsp;
<input type=radio name=present_p value=\"f\""

if { $present_p == "f" } {
    doc_body_append " checked "
}

doc_body_append ">No
</td>
<td>You might choose \"No\" if this product is part of a series.</td>
</tr>
<tr>
<td>When does this product become available for purchase?</td>
<td>[ad_dateentrywidget available_date $available_date]</td>
</tr>
"
if { !$multiple_retailers_p } {
    doc_body_append "<tr>
    <td>Shipping Price</td>
    <td><input type=text size=6 name=shipping value=\"$shipping\"></td>
    <td rowspan=3 valign=top>The \"Shipping Price\", \"Shipping Price - Additional\", and \"Weight\" fields
    may or may not be applicable, depending on the 
    <a href=\"../shipping-costs/\">shipping rules</a> you have set up for
    your ecommerce system.</td>
    </tr>
    <tr>
    <td>Shipping Price - Additional per item if ordering more than 1 (leave blank if same as Shipping Price above)</td>
    <td><input type=text size=6 name=shipping_additional value=\"$shipping_additional\"></td>
    </tr>
    "
} else {
    doc_body_append "[export_form_vars shipping shipping_additional]\n"
}
doc_body_append "<tr>
<td>Weight ([ad_parameter -package_id [ec_id] WeightUnits ecommerce])</td>
<td><input type=text size=3 name=weight value=\"$weight\"></td>
</tr>
<tr>
<td>Template</td>
<td>[ec_template_widget $category_list $template_id]</td>
<td>Select a template to use when displaying this product. If none is
selected, the product will be displayed with the system default template.</td>
</tr>
</table>

<p>
"

set n_user_classes [db_string num_user_classes_select "select count(*) from ec_user_classes"]
if { $n_user_classes > 0 && !$multiple_retailers_p} {
    doc_body_append "<h3>Special Prices for User Classes</h3>
    
    <p>

    <table noborder>
    "
    
    set first_class_p 1
    db_foreach user_classes_select "select user_class_id, user_class_name from ec_user_classes order by user_class_name" {
	doc_body_append "<tr><td>$user_class_name</td>
	<td><input type=text name=user_class_prices.$user_class_id size=6 value=\"[db_string price_select "select price from ec_product_user_class_prices where product_id=:product_id and user_class_id=:user_class_id" -default ""]\"></td>
	"

	if { $first_class_p } {
	    set first_class_p 0
	    doc_body_append "<td valign=top rowspan=$n_user_classes>Enter prices (no
	    special characters like \$) only if you want people in
	    user classes to be charged a different price than the
	    regular price.  If you leave user class prices blank,
	    then the users will be charged regular price.</td>\n"
	}
	doc_body_append "</tr>\n"
    }
    doc_body_append "</table>\n"
}

if { [db_string num_custom_product_fields_select "select count(*) from ec_custom_product_fields where active_p='t'"] > 0 } {

    doc_body_append "<h3>Custom Fields</h3>
    
    <p>

    <table noborder>
    "
    
    db_foreach custom_fields_select "select field_identifier, field_name, default_value, column_type from ec_custom_product_fields where active_p='t' order by creation_date" {
      doc_body_append "<tr><td>$field_name</td><td>[ec_custom_product_field_form_element $field_identifier $column_type [db_string custom_field_value_select "select $field_identifier from ec_custom_product_field_values where product_id=:product_id" -default "" ]]</td></tr>\n"
    }

    doc_body_append "</table>\n"
}

doc_body_append "<center>
<input type=submit value=\"Continue\">
</center>
</form>
[ad_admin_footer]
"

# /www/[ec_url_concat [ec_url] /admin]/products/add.tcl
ad_page_contract {

  Add a product.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
  
} {

}

ad_require_permission [ad_conn package_id] admin

doc_body_append "[ad_admin_header "Add a Product"]

<h2>Add a Product</h2>

[ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Products"] "Add Product"]

<hr>

All fields are optional except Product Name.
<p>
"
set multiple_retailers_p [ad_parameter -package_id [ec_id] MultipleRetailersPerProductP ecommerce]



doc_body_append "<form enctype=multipart/form-data method=post action=add-2>
<table>
<tr>
<td>Product Name</td>
<td colspan=2><input type=text name=product_name size=30></td>
</tr>
<tr>
<td>SKU</td>
<td><input type=text name=sku size=10></td>
<td>It's not necessary to include a SKU because the system generates its own
internal product_id to uniquely distinguish products.</td>
</tr>
<tr>
<td>Product Category</td>
<td>[ec_category_widget t]</td>
<td>Choose as many categories as you like.  The product will
be displayed on the web site in each of the categories you select.</td>
</tr>
"
if { !$multiple_retailers_p } {
    doc_body_append "<tr>
    <td>Stock Status</td>
    <td colspan=2>[ec_stock_status_widget]</td>
    </tr>
    "
} else {
    doc_body_append "[ec_hidden_input stock_status ""]\n"
}
doc_body_append "<tr>
<td>One-Line Description</td>
<td colspan=2><input type=text name=one_line_description size=60></td>
</tr>
<tr>
<td>Additional Descriptive Text</td>
<td colspan=2><textarea wrap rows=6 cols=60 name=detailed_description></textarea></td>
</tr>
<tr>
<td>Search Keywords</td>
<td colspan=2><textarea wrap rows=2 cols=60 name=search_keywords></textarea></td>
</tr>
<tr>
<td>Picture</td>
<td><input type=file size=10 name=upload_file></td>
<td>This picture (.gif or .jpg format) can be as large as you like.  A thumbnail will be automatically generated.  Note that file uploading doesn't work with Internet Explorer 3.0.</td>
</tr>
<tr>
<td>Color Choices</td>
<td><input type=text name=color_list size=40></td>
<td>This should be a comma-separated list of colors the user is allowed to choose from
when ordering.  If there are no choices, leave this blank.</td>
</tr>
<tr>
<td>Size Choices</td>
<td><input type=text name=size_list size=40></td>
<td>This should be a comma-separated list of sizes the user is allowed to choose from
when ordering.  If there are no choices, leave this blank.</td>
</tr>
<tr>
<td>Style Choices</td>
<td><input type=text name=style_list size=40></td>
<td>This should be a comma-separated list of styles the user is allowed to choose from
when ordering.  If there are no choices, leave this blank.</td>
</tr>
<tr>
<td>Email on Purchase</td>
<td><input type=text name=email_on_purchase_list size=40></td>
<td>This should be a comma-separated list of recipients to notify when a purchase is made. If you do not wish email to be sent, leave this blank.</td>
</tr>
<tr>
<td>URL where the consumer can get more info on the product</td>
<td colspan=2><input type=text name=url size=50 value=\"http://\"></td>
</tr>
"
if { !$multiple_retailers_p } {
    doc_body_append "<tr>
    <td>Regular Price</td>
    <td><input type=text size=6 name=price></td>
    <td>All prices are in [ad_parameter -package_id [ec_id] Currency ecommerce].  The price should
    be written as a decimal number (no special characters like \$).
    </tr>
    "
} else {
    doc_body_append "[ec_hidden_input price ""]\n"
}
doc_body_append "<tr>
<td>Is this product shippable?</td>
<td><input type=radio name=no_shipping_avail_p value=\"f\" checked>Yes
&nbsp;&nbsp;
<input type=radio name=no_shipping_avail_p value=\"t\">No
</td>
<td>You might choose \"No\" if this product is actually a service.</td>
</tr>
<tr>
<td>Should this product be displayed when the user does a search?</td>
<td><input type=radio name=present_p value=\"t\" checked>Yes
&nbsp;&nbsp;
<input type=radio name=present_p value=\"f\">No
</td>
<td>You might choose \"No\" if this product is part of a series.</td>
</tr>
<tr>
<td>When does this product become available for purchase?</td>
<td>[ad_dateentrywidget available_date]</td>
</tr>
"
if { !$multiple_retailers_p } {
    doc_body_append "<tr>
    <td>Shipping Price</td>
    <td><input type=text size=6 name=shipping></td>
    <td rowspan=3 valign=top>The \"Shipping Price\", \"Shipping Price - Additional\", and \"Weight\" fields
    may or may not be applicable, depending on the 
    <a href=\"../shipping-costs/index\">shipping rules</a> you have set up for
    your ecommerce system.</td>
    </tr>
    <tr>
    <td>Shipping Price - Additional per item if ordering more than 1 (leave blank if same as Shipping Price above)</td>
    <td><input type=text size=6 name=shipping_additional></td>
    </tr>
    "
} else {
    doc_body_append "[ec_hidden_input shipping ""]\n[ec_hidden_input shipping_additional ""]\n"
}
doc_body_append "<tr>
<td>Weight ([ad_parameter -package_id [ec_id] WeightUnits ecommerce])</td>
<td><input type=text size=3 name=weight></td>
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
    db_foreach user_class_select "
    select user_class_id, 
           user_class_name 
    from ec_user_classes 
    order by user_class_name" {
	doc_body_append "<tr><td>$user_class_name</td>
	<td><input type=text name=\"user_class_prices.$user_class_id\" size=6></td>
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
    
    db_foreach custom_fields_select "
    select field_identifier, 
           field_name, 
           default_value, 
           column_type 
    from ec_custom_product_fields 
    where active_p='t' order by creation_date" {
	doc_body_append "<tr><td>$field_name</td><td>[ec_custom_product_field_form_element $field_identifier $column_type $default_value]</td></tr>\n"
    }
    doc_body_append "</table>\n"

}

doc_body_append "<center>
<input type=submit value=\"Continue\">
</center>
</form>
[ad_admin_footer]
"

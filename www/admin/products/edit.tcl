# /www/[ec_url_concat [ec_url] /admin]/products/edit.tcl
ad_page_contract {

  Form for the user to edit the main fields in the ec_product table
  plus custom fields.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date June 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)

} {

  product_id:integer,notnull

}

ad_require_permission [ad_conn package_id] admin

set product_name [ec_product_name $product_id]

set title "Edit $product_name"
set context [list [list index Products] $title]

set multiple_retailers_p [parameter::get -package_id [ec_id] -parameter MultipleRetailersPerProductP]

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
from ec_products where product_id=:product_id"

# have to deal with category widget
set export_form_vars_html [export_form_vars product_id]
set category_list [db_list category_list_select "select category_id from ec_category_product_map where product_id=:product_id"]

set subcategory_list [db_list subcategory_list_select "select subcategory_id from ec_subcategory_product_map where product_id=:product_id"]

set subsubcategory_list [db_list subsubcategory_list_select "select subsubcategory_id from ec_subsubcategory_product_map where product_id=:product_id"]

set categorization_default [ec_determine_categorization_widget_defaults $category_list $subcategory_list $subsubcategory_list]

set product_category_html [ec_category_widget t $categorization_default]
if { $multiple_retailers_p } {
    set stock_status_html "[export_form_vars stock_status]\n"

} else {
    set stock_status_html [ec_stock_status_widget $stock_status]
    set price_html "[export_form_vars price]\n"
    set shipping_html "[export_form_vars shipping shipping_additional]\n"
}

set thumbnail [ec_linked_thumbnail_if_it_exists $dirname f]

if { [empty_string_p $url] } {
    set url "http://"
}
set currency [parameter::get -package_id [ec_id] -parameter Currency -default USD]

set no_shipping_avail_p_html ""
set shipping_avail_p_html ""
if { $no_shipping_avail_p == "f" } {
    set no_shipping_avail_p_html "checked"
} else {
    set shipping_avail_p_html "checked"
}

set present_p_html ""
set no_present_p_html ""
if { $present_p == "t" } {
    set present_p_html "checked"
} else {
    set no_present_p_html "checked"
}
set available_date_html [ad_dateentrywidget available_date $available_date]
set weight_units_html [parameter::get -package_id [ec_id] -parameter WeightUnits -default lbs]
set template_widget_html [ec_template_widget $category_list $template_id]

set n_user_classes [db_string num_user_classes_select "select count(*) from ec_user_classes"]
set n_user_classes_html ""
if { $n_user_classes > 0 && !$multiple_retailers_p} {
    set first_class_p 1
    db_foreach user_classes_select "select user_class_id, user_class_name from ec_user_classes order by user_class_name" {
        append n_user_classes_html "<tr><td>$user_class_name</td>
	<td><input type=text name=user_class_prices.$user_class_id size=6 value=\"[db_string price_select "select price from ec_product_user_class_prices where product_id=:product_id and user_class_id=:user_class_id" -default ""]\"></td>"

        if { $first_class_p } {
            set first_class_p 0
            doc_body_append "<td valign=top rowspan=$n_user_classes>Enter prices (no
	    special characters like \$) only if you want people in
	    user classes to be charged a different price than the
	    regular price.  If you leave user class prices blank,
	    then the users will be charged regular price.</td>\n"
        }
        append n_user_classes_html "</tr>\n"
    }
}

set custom_product_fields_html ""
set n_custom_product_fields [db_string num_custom_product_fields_select "select count(*) from ec_custom_product_fields where active_p='t'"]
if { $n_custom_product_fields > 0 } {
    db_foreach custom_fields_select "select field_identifier, field_name, default_value, column_type from ec_custom_product_fields where active_p='t' order by creation_date" {
        set current_field_value [db_string custom_field_value_select "select $field_identifier from ec_custom_product_field_values where product_id=:product_id" -default "$default_value" ]
        # check for cases where field is blank and nontext, because custom_field_value_select -default does not catch them
        if { [empty_string_p $current_field_value] && [regexp $column_type "timestampdatenumericintegerboolean"]} {
            set current_field_value $default_value
        }
        append custom_product_fields_html "<tr><td>$field_name</td><td>[ec_custom_product_field_form_element $field_identifier $column_type $current_field_value]</td></tr>\n"
    }
}

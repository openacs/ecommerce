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

set title "Add a Product"
set context [list [list index Products] $title]

set currency [parameter::get -package_id [ec_id] -parameter Currency]
set multiple_retailers_p [parameter::get -package_id [ec_id] -parameter MultipleRetailersPerProductP -default 0]
set weight_units [parameter::get -package_id [ec_id] -parameter WeightUnits -default lbs] 

if { $multiple_retailers_p } {
    set stock_status_html [ec_hidden_input stock_status ""]
    set price_html [ec_hidden_input price ""]
    set shipping_html [ec_hidden_input shipping ""]
    set shipping_additional_html [ec_hidden_input shipping_additional ""]
} else {
    set stock_status_html [ec_stock_status_widget]
    set price_html "" 
} 
set available_date "[clock format [clock seconds] -format "%Y-%m-%d"]"
set available_date_html [ad_dateentrywidget $available_date]
set product_category_html [ec_category_widget t]
set n_user_classes [db_string num_user_classes_select "select count(*) from ec_user_classes"]
if { $n_user_classes > 0 && !$multiple_retailers_p} {
    set first_class_p 1
    set user_classes_html ""

    db_foreach user_class_select "
    select user_class_id, 
           user_class_name 
    from ec_user_classes 
    order by user_class_name" {
	append user_classes_html "<tr><td>$user_class_name</td>
	<td><input type=text name=\"user_class_prices.$user_class_id\" size=6></td>"

        if { $first_class_p } {
            set first_class_p 0
            append user_classes_html "<td valign=top rowspan=$n_user_classes>Enter prices (no
	    special characters like \$) only if you want people in
	    user classes to be charged a different price than the
	    regular price.  If you leave user class prices blank,
	    then the users will be charged regular price.</td>\n"
        }
        append user_classes_html "</tr>\n"
    }
}

set n_custom_product_fields [db_string num_custom_product_fields_select "select count(*) from ec_custom_product_fields where active_p='t'"]
if { $n_custom_product_fields > 0 } {
    set custom_product_fields_html ""
     db_foreach custom_fields_select "
    select field_identifier, 
           field_name, 
           default_value, 
           column_type 
    from ec_custom_product_fields 
    where active_p='t' order by creation_date" {
	append custom_product_fields_html "<tr><td>$field_name</td><td>[ec_custom_product_field_form_element $field_identifier $column_type $default_value]</td></tr>\n"
    }
}


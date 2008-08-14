ad_page_contract {

    Main admin page for a single product.

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date June 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date May 2002

} {
    product_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

# Have to get everything about this product from ec_products,
# ec_custom_product_field_values (along with the info about the fields
# from ec_custom_product_fields), ec_category_product_map,
# ec_subcategory_product_map, ec_subsubcategory_product_map

db_0or1row product_select "
    select * 
    from ec_products 
    where product_id = :product_id"

# We know these won't conflict with the ec_products columns because of
# the constraint in custom-field-add-2.tcl

db_0or1row custom_fields_select "
    select * 
    from ec_custom_product_field_values
    where product_id = :product_id"
set category_list [db_list categories_select "
    select category_id
    from ec_category_product_map
    where product_id = :product_id"]
set subcategory_list [db_list subcategories_select "
    select subcategory_id
    from ec_subcategory_product_map
    where product_id = :product_id"]
set subsubcategory_list [db_list subsubcategories_select "
    select subsubcategory_id
    from ec_subsubcategory_product_map
    where product_id = :product_id"]
set multiple_retailers_p [ad_parameter -package_id [ec_id] MultipleRetailersPerProductP ecommerce]
set currency [ad_parameter -package_id [ec_id] Currency ecommerce]
set n_professional_reviews [db_string n_professional_reviews_select "
    select count(*) 
    from ec_product_reviews
    where product_id = :product_id"]

if { $n_professional_reviews == 0 } { 
    set product_review_anchor "none yet; click to add"
} else {
    set product_review_anchor $n_professional_reviews
}

set n_customer_reviews [db_string n_customer_reviews_select "
    select count(*) 
    from ec_product_comments
    where product_id = :product_id"]

if { $n_customer_reviews == 0 } {
    set customer_reviews_link "none yet"
} else {
    set customer_reviews_link "<a href=\"../customer-reviews/index-2?[export_url_vars product_id]\">$n_customer_reviews</a>"
}

set n_links_to [db_string n_links_to_select "
    select count(*) 
    from ec_product_links
    where product_b = :product_id"]

set n_links_from [db_string n_links_from_select "
    select count(*) 
    from ec_product_links
    where product_a = :product_id"]

if { $multiple_retailers_p } {
    set price_row ""
} else {
    if { [db_string sale_select "
	select count(*) 
	from ec_sale_prices_current 
	where product_id = :product_id"] > 0 } {
	set sale_prices_anchor "on sale; view price"
    } else {
	set sale_prices_anchor "put on sale"	
    }
    set price_row "
	<tr>
	  <td>Regular Price:</td>
	  <td>
	    [ec_message_if_null [ec_pretty_price $price $currency]]
	    (<a href=\"sale-prices?[export_url_vars product_id price]\">$sale_prices_anchor</a>)
	  </td>
	</tr>"
}

if { $no_shipping_avail_p == "f" } {
    set no_shipping_avail_p_for_display "Shipping Avail"
} else {
    set no_shipping_avail_p_for_display "No Shipping Avail"
}

set no_shipping_avail_p_row "
    <tr>
      <td>Shipping Avail/No Shipping Avail:</td>
      <td>
        $no_shipping_avail_p_for_display
        (<a href=\"toggle-no-shipping-avail-p?[export_url_vars product_id]\">toggle</a>)
      </td>
    </tr>"

if { $active_p == "t" } {
    set active_p_for_display "Active"
} else {
    set active_p_for_display "Discontinued"
}

set active_p_row "
    <tr>
      <td>Active/Discontinued:</td>
      <td>
        $active_p_for_display
        (<a href=\"toggle-active-p?[export_url_vars product_id]\">toggle</a>)
      </td>
    </tr>"

if [empty_string_p $dirname] {
    set dirname_cell "something is wrong with this product; there is no place to put files!"
} else {
    set dirname_cell "$dirname (<a href=\"supporting-files-upload?[export_url_vars product_id]\">Supporting Files</a>)"
}

set title $product_name
set context [list $title]

set export_product_id_var [export_url_vars product_id]

set linked_thumbnail_html [ec_linked_thumbnail_if_it_exists $dirname]


if { !$multiple_retailers_p } {
    if { ![empty_string_p $stock_status] } {
        set stock_status_html [util_memoize "ad_parameter -package_id [ec_id] \"StockMessage[string toupper $stock_status]\"" [ec_cache_refresh]]
    }
    set user_class_select_html ""
    db_foreach user_class_select "
	select user_class_id, user_class_name 
	from ec_user_classes
	order by user_class_name" {

	    set temp_price [db_string temp_price_select "
		select price 
		from ec_product_user_class_prices
		where product_id = :product_id
		and user_class_id = :user_class_id" -default ""]
	
	    append user_class_select_html "
		<tr>
		   <td>$user_class_name Price:</td>
		   <td>[ec_message_if_null [ec_pretty_price $temp_price $currency]]</td>
		</tr>"
    }

} else {

    set stock_status_html [ec_message_if_null $stock_status]

}
set export_product_id_name_var [export_url_vars product_id product_name]
set custom_fields_iteration_html ""
db_foreach custom_fields_iteration "
    select field_identifier, field_name, column_type
    from ec_custom_product_fields
    where active_p = 't'" {

    if { [info exists $field_identifier] } {
        append custom_fields_iteration_html "
	    <tr>
	      <td>$field_name:</td>
	      <td>"

        if { $column_type == "char(1)" } {
            append custom_fields_iteration_html "[ec_message_if_null [ec_PrettyBoolean [set $field_identifier]]]\n"
        } elseif { $column_type == "date" } {
            append custom_fields_iteration_html "[ec_message_if_null [util_AnsiDatetoPrettyDate [set $field_identifier]]]\n"
        } else {
            append custom_fields_iteration_html "[ec_display_as_html [ec_message_if_null [set $field_identifier]]]\n"
        }
        append custom_fields_iteration_html "</td></tr>"
    }
}

set sku_html [ec_message_if_null $sku]
set categorization_html [ec_category_subcategory_and_subsubcategory_display $category_list $subcategory_list $subsubcategory_list]
set shipping_html [ec_message_if_null [ec_pretty_price $shipping $currency]]
set shipping_additional_html [ec_message_if_null [ec_pretty_price $shipping_additional $currency]]
set one_line_description_html [ec_message_if_null $one_line_description]
set detailed_description_html [ec_display_as_html [ec_message_if_null $detailed_description]]
set search_keywords_html [ec_message_if_null $search_keywords]
set color_list_html [ec_message_if_null $color_list]
set size_list_html [ec_message_if_null $size_list]
set style_list_html [ec_message_if_null $style_list]
set email_on_purchase_list_html [ec_message_if_null $email_on_purchase_list]
set url_html [ec_message_if_null $url]
set present_p_html [ec_message_if_null [ec_PrettyBoolean $present_p]]
set weight_html "[ec_message_if_null $weight] [ec_decode $weight "" "" [ad_parameter -package_id [ec_id] WeightUnits ecommerce]]"
set template_html [ec_message_if_null [db_string template_name_select "select template_name from ec_templates where template_id=:template_id" -default "" ]]
set date_added_html [util_AnsiDatetoPrettyDate $creation_date]
set date_available_html [util_AnsiDatetoPrettyDate $available_date]

# Set audit variables audit_name, audit_id, audit_id_column,
# return_url, audit_tables, main_tables

set audit_name $product_name
set audit_id $product_id
set audit_id_column "product_id"
set return_url "[ad_conn url]?[export_url_vars product_id]"
set audit_tables [list ec_products_audit ec_custom_p_field_values_audit ec_category_product_map_audit ec_subcat_prod_map_audit ec_subsubcat_prod_map_audit]
set main_tables [list ec_products ec_custom_product_field_values ec_category_product_map ec_subcategory_product_map ec_subsubcategory_product_map]

set audit_url_html "[ec_url_concat [ec_url] /admin]/audit?[export_url_vars audit_name audit_id audit_id_column return_url audit_tables main_tables]"

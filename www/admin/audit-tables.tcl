#  www/[ec_url_concat [ec_url] /admin]/audit-tables.tcl
ad_page_contract {
  Gives the user a list of tables to audit.

  @author Jesse (jkoontz@mit.edu)
  @creation-date 7/18
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  table_names_and_id_column:optional
}

ad_require_permission [ad_conn package_id] admin

set title "Audit [ec_system_name]"
set context [list $title]

set table_names_and_id_col_exist [info exists table_names_and_id_column]
if { $table_names_and_id_col_exist } {
    set export_form_vars_html [export_form_vars table_names_and_id_column]
    set table_and_id_html "Audit for table [lindex $table_names_and_id_column 0]"
} else {
    set export_form_vars_html ""
    set table_and_id_html "<li>What table do you want to audit:
<select name=table_names_and_id_column><option value=\"ec_products ec_products_audit product_id\">Products</option>
<option value=\"ec_templates ec_templates_audit template_id\">Templates</option>
<option value=\"ec_user_classes ec_user_classes_audit user_class_id\">User Classes</option>
<option value=\"ec_user_class_user_map ec_user_class_user_map_audit user_class_id\">User Class to User Map by User class</option>
<option value=\"ec_user_class_user_map ec_user_class_user_map_audit user_id\">User Class to User Map by User</option>
<option value=\"ec_categories ec_categories_audit category_id\">Categories</option>
<option value=\"ec_subcategories ec_subcategories_audit subcategory_id\">Subcategories</option>
<option value=\"ec_subsubcategories ec_subsubcategories_audit subsubcategory_id\">Subsubcategories</option>
<option value=\"ec_email_templates ec_email_templates_audit email_template_id\">Email Templates</option>
<option value=\"ec_product_links ec_product_links_audit product_a\">Links from a Product</option>
<option value=\"ec_product_links ec_product_links_audit product_b\">Links to a Product</option>
<option value=\"ec_sales_tax_by_state ec_sales_tax_by_state_audit usps_abbrev\">Sales Tax</option>
<option value=\"ec_product_comments ec_product_comments_audit comment_id\">Customer Reviews</option>
<option value=\"ec_admin_settings ec_admin_settings_audit admin_setting_id\">Shipping Costs (and other defaults)</option>
<option value=\"ec_custom_product_fields ec_custom_product_fields_audit field_identifier\">Custom Product Fields</option>
<option value=\"ec_category_product_map ec_category_product_map_audit category_id\">Category to Product Map by category</option>
<option value=\"ec_category_product_map ec_category_product_map_audit product_id\">Category to Product Map by product</option>
<option value=\"ec_subcategory_product_map ec_subcategory_product_map_audit subcategory_id\">Subcategory to Product Map by subcategory</option>
<option value=\"ec_subcategory_product_map ec_subcategory_product_map_audit product_id\">Subcategory to Product Map by product</option>
<option value=\"ec_subsubcategory_product_map ec_subsubcat_product_map_audit subsubcategory_id\">Subsubcategory to Product Map by subsubcategory</option>
<option value=\"ec_subsubcategory_product_map ec_subsubcat_product_map_audit product_id\">Subsubcategory to Product Map by product</option></select></li>"
}

set start_point_html "[ad_dateentrywidget start_date ""] [ec_timeentrywidget start_time ""]"
set end_point_html "[ad_dateentrywidget end_date] [ec_timeentrywidget end_time]"

set system_name [ec_system_name]


#  www/[ec_url_concat [ec_url] /admin]/audit-tables.tcl
ad_page_contract {
  Gives the user a list of tables to audit.

  @author Jesse (jkoontz@mit.edu)
  @creation-date 7/18
  @cvs-id audit-tables.tcl,v 3.1.6.4 2000/09/06 22:11:07 kevin Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  table_names_and_id_column:optional
}

ad_require_permission [ad_conn package_id] admin

doc_body_append "
[ad_admin_header "Audit [ec_system_name]"]

<h2>Audit [ec_system_name]</h2>

[ad_admin_context_bar [list "index.tcl" Ecommerce([ec_system_name])] "Audit Tables"]

<hr>

This page will let you see all changes to one table of the
[ec_system_name] database over a specified period of time. <b>It is
recommended that you start with a narrow time window and expand as
needed. Some tables can become very large.</b>

<form method=post action=\"audit-table\">

<ul>
"

if { [info exists table_names_and_id_column] } {
    doc_body_append "[export_form_vars table_names_and_id_column]
    <blockquote>
    Audit for table [lindex $table_names_and_id_column 0]
    </blockquote>
"
} else {
    doc_body_append "
<li>What table do you want to audit:
<select name=table_names_and_id_column>
<option value=\"ec_products ec_products_audit product_id\">Products
<option value=\"ec_templates ec_templates_audit template_id\">Templates
<option value=\"ec_user_classes ec_user_classes_audit user_class_id\">User Classes
<option value=\"ec_user_class_user_map ec_user_class_user_map_audit user_class_id\">User Class to User Map by User class
<option value=\"ec_user_class_user_map ec_user_class_user_map_audit user_id\">User Class to User Map by User
<option value=\"ec_categories ec_categories_audit category_id\">Categories
<option value=\"ec_subcategories ec_subcategories_audit subcategory_id\">Subcategories
<option value=\"ec_subsubcategories ec_subsubcategories_audit subsubcategory_id\">Subsubcategories
<option value=\"ec_email_templates ec_email_templates_audit email_template_id\">Email Templates
<option value=\"ec_product_links ec_product_links_audit product_a\">Links from a Product
<option value=\"ec_product_links ec_product_links_audit product_b\">Links to a Product
<option value=\"ec_sales_tax_by_state ec_sales_tax_by_state_audit usps_abbrev\">Sales Tax
<option value=\"ec_product_comments ec_product_comments_audit comment_id\">Customer Reviews
<option value=\"ec_admin_settings ec_admin_settings_audit admin_setting_id\">Shipping Costs (and other defaults)
<option value=\"ec_custom_product_fields ec_custom_product_fields_audit field_identifier\">Custom Product Fields
<option value=\"ec_category_product_map ec_category_product_map_audit category_id\">Category to Product Map by category
<option value=\"ec_category_product_map ec_category_product_map_audit product_id\">Category to Product Map by product
<option value=\"ec_subcategory_product_map ec_subcategory_product_map_audit subcategory_id\">Subcategory to Product Map by subcategory
<option value=\"ec_subcategory_product_map ec_subcategory_product_map_audit product_id\">Subcategory to Product Map by product
<option value=\"ec_subsubcategory_product_map ec_subsubcat_product_map_audit subsubcategory_id\">Subsubcategory to Product Map by subsubcategory
<option value=\"ec_subsubcategory_product_map ec_subsubcat_product_map_audit product_id\">Subsubcategory to Product Map by product
</select>
"
}

doc_body_append "
<p>

<li>When do you want to audit back to: (Leave blank to start at the begining of the table's history.)<br>
[ad_dateentrywidget start_date ""] [ec_timeentrywidget start_time ""]

<p>

<li>When do you want to audit up to:<br>
[ad_dateentrywidget end_date] [ec_timeentrywidget end_time]

</ul>

<center>
<b>Note: if the table is very large, this may take a while.</b><br>
<input type=submit value=Audit>
</center>

</form>

[ad_admin_footer]
"

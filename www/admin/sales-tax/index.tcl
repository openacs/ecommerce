#  www/[ec_url_concat [ec_url] /admin]/sales-tax/index.tcl
ad_page_contract {

  @author
  @creation-date
  @cvs-id index.tcl,v 3.2.2.6 2000/09/22 01:35:01 kevin Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

set page_html "[ad_admin_header "Sales Tax"]

<h2>Sales Tax</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] "Sales Tax"]

<hr>

<h3>Your Current Settings</h3>

<p>

<ul>
"

# for audit table
set table_names_and_id_column [list ec_sales_tax_by_state ec_sales_tax_by_state_audit usps_abbrev]



db_foreach get_sales_taxes "select state_name, tax_rate*100 as tax_rate_in_percent, decode(shipping_p,'t','Yes','No') as shipping_p
from ec_sales_tax_by_state, us_states
where ec_sales_tax_by_state.usps_abbrev = us_states.abbrev" {

    append page_html "<li>$state_name:
    <blockquote>
    Tax rate: $tax_rate_in_percent%<br>
    Charge tax on shipping? $shipping_p
    </blockquote>
    "
} if_no_rows {

    append page_html "No tax is currently charged in any state.\n"
}
append page_html "
</ul>

<p>

<h3>Change Your Settings</h3>

<p>

<blockquote>

Please select all the states in which you need to charge sales tax.  You will be asked
later what the tax rates are and whether to charge tax on shipping in those states.

<p>

<form method=post action=edit>
"

set current_state_list [db_list get_abbrevs "select usps_abbrev from ec_sales_tax_by_state"]

db_release_unused_handles

append page_html "[ec_multiple_state_widget $current_state_list]

<center>
<input type=submit value=\"Submit\">
</center>

</form>

</blockquote>

<p>

<h3>Clear All Settings</h3>

<blockquote>
If you want to start from scratch, <a href=\"clear\">clear all settings</a>.
</blockquote>

In general, you must collect sales tax on orders shipped to states
where you have some kind of physical presence, e.g., a warehouse, a
sales office, or a retail store.  A reliable source of data on sales
tax rates by zip code is 
<a href=\"http://www.salestax.com\">www.salestax.com</a>.

<p>

We tried to keep this module simple by ignoring the ugly fact of local
taxing jurisdictions (e.g., that New York City collects tax on top of
what New York State collects).  If you're a Fortune 500 company with
nexus in 50 states, you'll probably have to add in a fair amount of
complexity to collect tax more precisely or at least <em>remit</em>
sales tax more precisely.  See 
<a href=\"http://www.arsdigita.com/books/panda/ecommerce.html\">the ecommerce chapter
 of Philip and Alex's Guide to Web Publishing</a> for 
more on this mournful topic.

<h3>Audit Trail</h3>

<ul>
<li><a href=\"[ec_url_concat [ec_url] /admin]/audit-tables?[export_url_vars table_names_and_id_column]\">Audit Sales Tax Settings</a>
</ul>

[ad_admin_footer]
"

doc_return  200 text/html $page_html



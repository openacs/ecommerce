#  www/[ec_url_concat [ec_url] /admin]/sales-tax/edit.tcl
ad_page_contract {
    @param usps_abbrev the abbreviations of the states

  @author
  @creation-date
  @cvs-id edit.tcl,v 3.2.2.6 2000/09/22 01:35:01 kevin Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    usps_abbrev:multiple
}

ad_require_permission [ad_conn package_id] admin

# The only form element is a usps_abbrev multiple select.
# If I end up adding something else, I'll have to modify
# below and use it in conjunction with set_form_variables
set usps_abbrev_list $usps_abbrev


set page_html "[ad_admin_header "Sales Tax, Continued"]

<h2>Sales Tax, Continued</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Sales Tax"] "Edit"]

<hr>

Please specify the sales tax rates below for each state listed and whether tax
is charged on shipping in that state:

<p>

<form method=post action=edit-2>
[export_form_vars usps_abbrev_list]

<ul>
"


foreach usps_abbrev $usps_abbrev_list {
    append page_html "<li><b>[ec_state_name_from_usps_abbrev $usps_abbrev]:</b>
<blockquote>
Tax rate <input type=text name=tax_rate.${usps_abbrev} size=4 value=\"[db_string get_tax_rate "select tax_rate*100 from ec_sales_tax_by_state where usps_abbrev=:usps_abbrev" -default ""]\">%<br>
Charge tax on shipping? 
"

set shipping_p [db_string get_shipping_ps "select shipping_p from ec_sales_tax_by_state where usps_abbrev=:usps_abbrev" -default ""]
if { [empty_string_p $shipping_p] || $shipping_p == "t" } {
    append page_html "<input type=radio name=shipping_p.${usps_abbrev} value=t checked>Yes
    &nbsp; <input type=radio name=shipping_p.${usps_abbrev} value=f>No
    "
} else {
    append page_html "<input type=radio name=shipping_p.${usps_abbrev} value=t>Yes
    &nbsp; <input type=radio name=shipping_p.${usps_abbrev} value=f checked>No
    "
}

db_release_unused_handles

append page_html "</blockquote>
"
}

append page_html "</ul>

<center>
<input type=submit value=\"Submit\">
</center>

</form>
[ad_admin_footer]
"


doc_return  200 text/html $page_html








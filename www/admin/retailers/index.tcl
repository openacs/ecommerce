#  www/[ec_url_concat [ec_url] /admin]/retailers/index.tcl
ad_page_contract {
  This page displays current retailers  

  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

set page_html "[ad_admin_header "Retailer Administration"]

<h2>Retailer Administration</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] "Retailers"]

<hr>
<h3>Current Retailers</h3>
<ul>
"


db_foreach get_retailer_list "
   select retailer_id, 
          retailer_name, 
          decode(reach,'web',url,city || ', ' || usps_abbrev) as location 
   from ec_retailers 
   order by retailer_name" {

    append page_html "<li><a href=\"one?retailer_id=$retailer_id\">$retailer_name</a> ($location)\n"

} if_no_rows {

    append page_html "There are currently no retailers.\n"
}

append page_html "
</ul>
<p>
<h3>Actions</h3>
<ul>
<li><a href=\"add\">Add New Retailer</a>
</ul>
[ad_admin_footer]
"

doc_return  200 text/html $page_html

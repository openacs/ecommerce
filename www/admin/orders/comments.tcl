#  www/[ec_url_concat [ec_url] /admin]/orders/comments.tcl
ad_page_contract {
  Add and edit comments for an order.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  order_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

doc_body_append "[ad_admin_header "Comments"]

<h2>Comments</h2>

[ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Orders"] [list "one?[export_url_vars order_id]" "One Order"] "Comments"]

<hr>

<form method=post action=comments-edit>
[export_form_vars order_id]

Please add or edit comments below:

<br>

<blockquote>
<textarea name=cs_comments rows=15 cols=50 wrap>[db_string comments_select "select cs_comments from ec_orders where order_id=:order_id"]</textarea>
</blockquote>

<p>
<center>
<input type=submit value=\"Submit\">
</center>

</form>

[ad_admin_footer]
"

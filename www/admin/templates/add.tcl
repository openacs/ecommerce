#  www/[ec_url_concat [ec_url] /admin]/templates/add.tcl
ad_page_contract {
    @param based_on optional to base template on

  @author
  @creation-date
  @cvs-id add.tcl,v 3.1.6.4 2000/09/22 01:35:03 kevin Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    based_on:optional
}

ad_require_permission [ad_conn package_id] admin

set page_html "[ad_admin_header "Add a Template"]

<h2>Add a Template</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Product Templates"] "Add a Template"]

<hr>
"

if { [info exists based_on] && ![empty_string_p $based_on] } {
    
    set template [db_string get_template "select template from ec_templates where template_id=:based_on"]
} else {
    set template ""
}

append page_html "<form method=post action=add-2>

Name: <input type=text name=template_name size=30>

<p>

ADP template:<br>
<textarea name=template rows=10 cols=60>$template</textarea>

<p>

<center>
<input type=submit value=\"Submit\">
</center>

</form>

[ad_admin_footer]
"


doc_return  200 text/html $page_html

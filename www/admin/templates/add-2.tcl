#  www/[ec_url_concat [ec_url] /admin]/templates/add-2.tcl
ad_page_contract {
    @param template the template
    @param template_name the name of the template

  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    template_name
    template:allhtml

}

ad_require_permission [ad_conn package_id] admin

set exception_count 0
set exception_text ""


if { ![info exists template] || [empty_string_p $template] } {
    incr exception_count
    append exception_text "<li>You forgot to enter anything into the ADP template box.\n"
}

set f [ec_adp_function_p $template]
if {$f != 0} {
    incr exception_count
    append exception_text "
    <li>We're sorry, but templates added here cannot
    have functions in them for security reasons. Only HTML and 
    <%= \$variable %> style code may be used.  We found <tt>$function</tt> in this template"

}

if { $exception_count > 0 } {
    ad_return_complaint $exception_count $exception_text
    return
}

set page_html "[ad_admin_header "Confirm Template"]

<h2>Confirm Template</h2>

[ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Product Templates"] "Confirm Template"]

<hr>
"


set template_id [db_nextval ec_template_id_sequence]

append page_html "<form method=post action=add-3>
[export_form_vars template_id template_name template]

Name: 

<p>

<blockquote>
<pre>$template_name</pre>
</blockquote>

<p>

ADP template:

<p>

<blockquote>
<pre>
[ns_quotehtml $template]
</pre>
</blockquote>

<p>

<center>
<input type=submit value=\"Confirm\">
</center>

</form>

[ad_admin_footer]
"
db_release_unused_handles
doc_return 200 text/html $page_html

ad_page_contract {
    Prints out information and source code on a defined site-wide style.

    @param style_name

    @author ?
    @creation-date ?
    @cvs-id style-one.tcl,v 3.2.2.4 2000/09/22 01:37:23 kevin Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    style_name:notnull
}

doc_return  200 text/html "[ad_admin_header "One Style"]
<h2>One Style</h2>

defined in [nsv_get ec_styletag_source_file $style_name], part of the
<a href=\"styles\">style module</a> of the ArsDigita Community System

<hr>

This page shows the available information on one style defined using <code>ec_register_styletag</code>.

<h3>$style_name</h3>

<blockquote>

[nsv_get ec_styletag $style_name]

</blockquote>

Source code:
<pre>
[ad_quotehtml [info body ec_style_$style_name]]
</pre>

[ad_admin_footer]
"


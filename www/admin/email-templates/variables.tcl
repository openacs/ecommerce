# variables.tcl

ad_page_contract {
    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

append doc_body "[ad_admin_header "Note on Variables"]

<h2>Note on Variables</h2>

[ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Email Templates"] "Note on Variables"]

<hr>

We ask you to list the variables you're using so that programmers will know what things they should substitute for in the body of the email.  Variable names should be descriptive so that it's obvious to the programmers what each one means.

<p>

An example:

<p>

<table border=0 cellspacing=0 cellpadding=15>
<tr>
<td valign=top align=right><b>Title</td>
<td valign=top>New Order</td>
</tr>
<tr>
<td valign=top align=right><b>Variables</td>
<td valign=top>confirmed_date_here, address_here, order_summary_here, price_here, shipping_here, tax_here, total_here</td>
</tr>
<tr>
<td valign=top align=right><b>When Sent</td>
<td valign=top>This email will automatically be sent out after an order has been authorized</td>
</tr>
<tr>
<td valign=top align=right><b>Subject Line</td>
<td valign=top>Your Order</td>
</tr>
<tr>
<td valign=top align=right><b>Message</td>
<td valign=top>[ec_display_as_html "Thank you for your order.  We received your order on 
confirmed_date_here.

To view the status of your order at any time, please log in to 
www.whatever.com and view \"Your Account\".

The following is your order information.  If you need to contact us 
regarding this information, please contact info@whatever.com.

order_summary_here

Shipping Address:
address_here

Price: price_here
S&H:   shipping_here
Tax:   tax_here
-----------------
Total: total_here

Thank you. 

Sincerely,
Customer Service
info@whatever.com
http://www.whatever.com"]</td>
</tr>
<tr>
<td valign=top align=right><b>Issue Type</td>
<td valign=top>new order</td>
</tr>
</table>

[ad_admin_footer]
"


doc_return  200 text/html $doc_body




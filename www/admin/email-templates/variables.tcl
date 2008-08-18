# variables.tcl
ad_page_contract {
    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

set title "Note on Variables"
set context [list [list index "Email Templates"] $title]

set example_email [ec_display_as_html "Thank you for your order.  We received your order on 
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
http://www.whatever.com"]

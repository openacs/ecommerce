# gift-certificate-add.tcl

ad_page_contract { 
    @param user_id
    @param amount
    @param expires

    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    user_id
    amount
    expires
}

ad_require_permission [ad_conn package_id] admin

# make sure there's an amount
if { ![info exists amount] || [empty_string_p $amount] } {
    ad_return_complaint 1 "<li>No gift certificate value specified.</li>"
    return
}

set title  "Confirm New Gift Certificate"
set context [list [list index "Customer Service"] $title]

set expiration_to_print [db_string get_exipre_from_Db "select [ec_decode $expires "" "null" $expires] from dual"]
set expiration_to_print [ec_decode $expiration_to_print "" "never" [util_AnsiDatetoPrettyDate $expiration_to_print]]

set currency [parameter::get -package_id [ec_id] -parameter Currency -default "USD"]
set price_html [ec_pretty_price $amount $currency]

set user_link "<a href=\"[ec_acs_admin_url]users/one?user_id=$user_id\">[db_string get_full_name "select first_names || ' ' || last_name from cc_users where user_id=:user_id"]</a>"

set export_form_vars_html [export_form_vars user_id amount expires]


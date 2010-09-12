ad_library {

    Paypal procs

    @creation-date  Aug 2010
}

ad_proc -public ecds_paypal_checkout_button {
    product_list_of_lists
    tax
    weight
    shipping
    invoice_ref
    {thankyou_url}
} {
    returns html fragment for checking out via PayPal standard "checkout update" process
     product_list_of_lists is quantity,item_number,item_name,amount_each
} {
# paypal variable notes at: https://cms.paypal.com/us/cgi-bin/?cmd=_render-content&content_ID=developer/e_howto_html_Appx_websitestandard_htmlvariables
# var 'rm' has special meaning on return:
#
#Return method. The FORM METHOD used to send data to the URL specified by the return variable after payment completion. Allowable values:
#      0 - all shopping cart transactions use the GET method
#      1 - the payer's browser is redirected to the return URL by the GET method, and no transaction variables are sent
#      2 - the payer's browser is redirected to the return URL by the POST method, and all transaction variables are also posted
# The default is 0.
#Note: The rm variable takes effect only if the return variable is also set.
  
#by using rm = 2, can numbers be verified automatically?  exploring this.

    set currency [parameter::get -package_id [ec_id] -parameter Currency -default USD]
    set business [parameter::get -package_id [ec_id] -parameter PayPalBusiness -default [ec_system_owner]]
    set paypal_button_html "<form action=\"https://www.paypal.com/cgi-bin/webscr\" method=\"post\">
<input type=\"hidden\" name=\"cmd\" value=\"_cart\">
<input type=\"hidden\" name=\"upload\" value=\"1\">
<input type=\"hidden\" name=\"currency_code\" value=\"$currency\">
<input type=\"hidden\" name=\"business\" value=\"$business\">"

    set row 0
    foreach bom_line_list $product_list_of_lists {
        incr row
        set quantity [lindex $bom_line_list 0]
        set item_number [lindex $bom_line_list 1]
        set item_name [lindex $bom_line_list 2]
        set amount [lindex $bom_line_list 3]
        if { $item_number ne "" } {
            append paypal_button_html "<input type=\"hidden\" name=\"item_number_$row\" value=\"${item_number}\">"
        }
        append paypal_button_html "<input type=\"hidden\" name=\"item_name_$row\" value=\"${item_name}\">
<input type=\"hidden\" name=\"amount_$row\" value=\"$amount\">
<input type=\"hidden\" name=\"quantity_$row\" value=\"$quantity\">\n"
    }
    if { thankyou_url eq "" } {
        set thankyou_url "[ec_insecure_location][ec_url]/thank-you-paypal"
    }
    set weight_unit [parameter::get -package_id [ec_id] -parameter WeightUnits -default "lbs"]
    append paypal_button_html "<input type=\"hidden\" name=\"tax_cart\" value=\"$tax\">
<input type=\"hidden\" name=\"weight_cart\" value=\"$weight\">
<input type=\"hidden\" name=\"weight_unit\" value=\"${weight_unit}\">
<input type=\"hidden\" name=\"shipping\" value=\"$shipping\">
<input type=\"hidden\" name=\"invoice\" value=\"${invoice_ref}\">
<input type=\"hidden\" name=\"paymentaction\" value=\"authorization\">
<input type=\"hidden\" name=\"return\" value=\"${thankyou_url}\">
<input type=\"hidden\" name=\"rm\" value=\"2\">

<input type=\"submit\" value=\"PayPal\">
</form>"
    return $paypal_button_html
}

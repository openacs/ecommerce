#     Display the ecommerce toolbar containing 
#     a link to order gift certificates (if they are allowed) and links
#     to the shopping cart and store account.

# Determine the URLs to the Shopping Cart and store Account.
# Get the ecommerce package url
set ecommerce_base_url [ec_url]

if {![info exists current_location]} {
    set current_location [file tail [ad_conn file]]
}

set ec_cart_link [ec_insecurelink [file join $ecommerce_base_url "shopping-cart"]]
set ec_account_link [ec_insecurelink [file join $ecommerce_base_url "account"]]
set ec_gift_cert_order_link [ec_insecurelink [file join $ecommerce_base_url "gift-certificate-order"]]

# Get the name of the ecommerce package
set ec_system_name [ec_system_name]

# Check if gift certificates can be bought.
set gift_certificates_are_allowed [parameter::get -package_id [ec_id] -parameter SellGiftCertificatesP -default 0]

set paypal_standard_mode [parameter::get -parameter PayPalStandardMode]
set user_session_id [ec_get_user_session_id]
set n_items_in_cart [db_string get_n_items "select count(*) from ec_orders o, ec_items i
    where o.order_id=i.order_id and o.user_session_id=:user_session_id and o.order_state='in_basket'"]
if { $paypal_standard_mode == 5 && $n_items_in_cart == 0 } {            
    set paypal_business_ref [parameter::get -parameter PayPalBusinessRef]
    set use_paypal_shopping_cart_p 1
} else {
    set use_paypal_shopping_cart_p 0
}
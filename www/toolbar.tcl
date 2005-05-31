#     Display the ecommerce toolbar containing a product search widget, 
#     a link to order gift certificates (if they are allowed) and links
#     to the shopping cart and store account.

#     @param category_id
#     @param subcategory_id
#     @param search_text
#     @current_location

#     @author Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
#     @cvs-id $Id$
#     @creation-date September 2002

# Create empty values for each optional parameter that has not been passed from a master template.
foreach parameter {combocategory_id category_id subcategory_id search_text current_location} {
    if {![info exists $parameter]} {
	set $parameter {}
    }
}

# we'll show a search widget at the top if there are categories to search in
if { ![empty_string_p [db_string get_check_of_categories "select 1 from dual where exists (select 1 from ec_categories)" -default ""]] } {
    # Create a context aware search widget to search for products.

    # Decode the combo of category and subcategory ids
    if { ![empty_string_p $combocategory_id] } {
        set category_id [lindex [split $combocategory_id "|"] 0]
        set subcategory_id [lindex [split $combocategory_id "|"] 1]
    }
    set ec_search_widget [ec_search_widget "$category_id|$subcategory_id"  $search_text]
} else {
    set ec_search_widget ""
}

# Determine the URLs to the Shopping Cart and store Account.
# Get the ecommerce package url
set ecommerce_base_url [ec_url]

set ec_cart_link [ec_insecurelink [file join $ecommerce_base_url "shopping-cart"]]
set ec_account_link [file join $ecommerce_base_url "account"]
set ec_gift_cert_order_link [ec_insecurelink [file join $ecommerce_base_url "gift-certificate-order"]]

# Get the name of the ecommerce package
set ec_system_name [ec_system_name]

# Check if gift certificates can be bought.
set gift_certificates_are_allowed [ad_parameter -package_id [ec_id] SellGiftCertificatesP ecommerce]

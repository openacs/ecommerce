#  www/ecommerce/gift-certificate-order.tcl
ad_page_contract {
 describes gift certificates and presents a link to order a gift certificate
  @author
  @creation-date
  @cvs-id gift-certificate-order.tcl,v 3.1.10.5 2000/08/17 21:23:07 seb Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {

}



set system_name [ad_system_name]
set expiration_time [ec_decode [util_memoize {ad_parameter -package_id [ec_id] GiftCertificateMonths ecommerce} [ec_cache_refresh]] "12" "1 year" "24" "2 years" "[util_memoize {ad_parameter -package_id [ec_id] GiftCertificateMonths ecommerce} [ec_cache_refresh]] months"]
set minimum_amount [ec_pretty_price [util_memoize {ad_parameter -package_id [ec_id] MinGiftCertificateAmount ecommerce} [ec_cache_refresh]]]
set maximum_amount [ec_pretty_price [util_memoize {ad_parameter -package_id [ec_id] MaxGiftCertificateAmount ecommerce} [ec_cache_refresh]]]

# wtem@olywa.net, 2001-03-29
# changed to relative link from ec_securelink
# ec_redirect_to_https_if_possible_and_necessary handles secure connections
# from linked to pages
set order_url "gift-certificate-order-2"

ec_return_template

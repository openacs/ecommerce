#  www/ecommerce/gift-certificate-thank-you.tcl
ad_page_contract {
 the user is redirected to this page from gift-certificate-finalize-order.tcl if
 their gift certificate order has succeeded

 this page displays a thank you message
  @author
  @creation-date
  @cvs-id gift-certificate-thank-you.tcl,v 3.1.10.4 2000/08/17 21:23:07 seb Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}



set home_page "[ec_insecure_location][ec_url]index"



ec_return_template

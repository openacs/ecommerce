# /tcl/ecommerce-user-contributions-summary.tcl
ad_library {

   Exists only to show the site owner a user's activities
   on the site in the ecommerce system.

  @cvs-id ecommerce-user-contributions-summary.tcl,v 3.1.6.3 2000/08/17 17:37:17 seb Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)

  @author philg@mit.edu
  @creation-date November 1, 1999

}

if { ![info exists ad_user_contributions_summary_proc_list] || [util_search_list_of_lists $ad_user_contributions_summary_proc_list "Ecommerce" 0] == -1 } {
    lappend ad_user_contributions_summary_proc_list [list "Ecommerce" ecommerce_user_contributions 0]
}

ad_proc ecommerce_user_contributions { user_id purpose} {Returns list items, one for each classified posting} {
    if { $purpose != "site_admin" } {
	return [list]
    }
    if ![ad_parameter -package_id [ec_id] EnabledP ecommerce 0] {
	return [list]
    }
    set moby_string ""
    append moby_string "<ul>
    <li>Ecommerce User Classes: [ec_user_class_display $user_id t]
    
    <p>

    <li><a href=\"[ec_url_concat [ec_url] /admin]/customer-service/gift-certificates?user_id=$user_id\">Gift Certificates</a> (balance [ec_pretty_price [db_string get_gift_certificate_balances "select ec_gift_certificate_balance(:user_id) from dual"]])
    </ul>

    <h4>Addresses</h4>
    <ul>
    "

    set address_id_list [db_list get_addresses "select address_id
from ec_addresses where user_id = :user_id"]

    foreach address_id $address_id_list  {
	append moby_string "<li>[ec_display_as_html [ec_pretty_mailing_address_from_ec_addresses $address_id]]<p>\n"
    }

    append moby_string "
    </ul>

    <h4>Order History</h4>

    [ec_all_orders_by_one_user $user_id]

    <h4>Customer Service History</h4>
    <ul>
    <li><a href=\"[ec_url_concat [ec_url] /admin]/customer-service/interaction-summary?user_id=$user_id\">Interaction Summary</a>
    <li>Individual Issues:
    [ec_all_cs_issues_by_one_user $user_id]
    </ul>

    <h4>Product Reviews</h4>
    <ul>
    "

    db_foreach get_product_reviews_for_user "select c.comment_id, p.product_name, comment_date
    from ec_product_comments c, ec_products p
    where c.product_id = p.product_id
    and user_id = :user_id" {

	append moby_string "<li>[util_AnsiDatetoPrettyDate $comment_date] : <a href=\"[ec_url_concat [ec_url] /admin]/customer-reviews/one?[export_url_vars comment_id]\">$product_name</a>\n"
    }

    append moby_string "</ul>
    "
    if [empty_string_p $moby_string] {
	return [list]
    } else {
	return [list 0 "Ecommerce" $moby_string]
    }

}



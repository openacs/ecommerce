ad_page_contract {

    Add a creditcard.

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    order_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

doc_body_append "
    [ad_admin_header "New Credit Card"]

    <h2>New Credit Card</h2>

    [ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Orders"] [list "one?[export_url_vars order_id]" "One Order"] "New Credit Card"]

    <hr>
    <p>Entering a new credit card will cause all future transactions
    involving this order to use this credit card.  However, it will
    not have any effect on transactions that are currently
    underway (e.g., if a transaction has already been authorized
    with a different credit card, that credit card will be used to
    complete the transaction). </p>"

db_0or1row select_billing_address "
      select c.billing_address, a.country_code
      from ec_creditcards c, ec_orders o, ec_addresses a
      where o.creditcard_id = c.creditcard_id
      and a.address_id = c.billing_address
      and o.order_id = :order_id
      limit 1"

doc_body_append "
  <table>
    <tr>
      <td>
	[ec_display_as_html [ec_pretty_mailing_address_from_ec_addresses $billing_address]]
      </td>
      <td>"
doc_body_append "
      </td>
      <td width=\"20%\">
      </td>
      <td valign=\"top\">
	<form method=\"post\" action=\"creditcard-add-2\">
	  <input type=\"hidden\" name=\"address_id\" value=\"$billing_address\"></input>
          [export_form_vars order_id]
	  <table>
	    <tr>
	      <td>Credit card number:</td>
	      <td><input type=\"text\" name=\"creditcard_number\" size=\"21\"></td>
	    </tr>
	    <tr>
	      <td>Type:</td>
	      <td>[ec_creditcard_widget]</td>
	      <td>
		<center>
		  <input type=\"submit\" value=\"Submit\">
		</center>
	      </td>
	    </tr>
	    <tr>
	      <td>Expires:</td>
	      <td>[ec_creditcard_expire_1_widget] [ec_creditcard_expire_2_widget]</td>
	    </tr>
	  </table>
	</form>
      </td>
    </tr>
  </table>
    [ad_admin_footer]"

<ec_header>Payment Info</ec_header>

<ec_navbar>checkout {payment info}</ec_navbar>

<h2>Payment Info</h2>

<blockquote>

<p>Your order will not be complete until you have confirmed the total in the next step.
<% ns_puts [ad_parameter -package_id [ec_id] SystemName ecommerce] %> will not charge your card 
without your confirmation of the total.</p>

<form method=post action=<%= "\"$form_action\"" %>>

<%

# We have to use a little bit of Tcl to take care of cases like:
# the customer's gift certificate balance covers the cost of
# the order (so they don't need a credit card form) or they
# are/aren't allowed to reuse old credit card numbers

# If you edit the text, remember to put a backslash before any
# embedded quotation marks (\").

# first set certificate_message so we can use it later
if { $gift_certificate_covers_whole_order } {
	set certificate_message "Your gift certificate balance covers the
	total cost of your order.  No need to enter any payment information!
	<p>"
} elseif { $gift_certificate_covers_part_of_order } {
	set certificate_message "Your gift certificate balance takes care of
	$certificate_amount of your order!  Please enter credit card information
	to pay for the rest.
	<p>"
} else {
	set certificate_message ""
}

# now set credit_card_message_1 and credit_card_message_2 that will be printed
# if the user is allowed to reuse old credit cards (depending on admin settings)

set credit_card_message_1 "Since we already have a credit card on file for you,
you can just click on the button next to it to use it for this order.
<p>"

set credit_card_message_2 "<p>
<b>Or enter a new credit card for billing:</b>
<br>
If you're using a new card, please enter the full credit card number below.  
<p>"

# we're done setting variables
%>

<%= $certificate_message %>

<%
# We have to go back into Tcl to take care of the case where the gift certificate
# doesn't cover the whole order (notice that there's an "!", which means "not", inside
# the "if statement")

if { !$gift_certificate_covers_whole_order } {

    # ns_puts means "print this"
    ns_puts "
    <a href=\"gift-certificate-claim.tcl\">Click here to claim a new gift certificate</a>
    <p>
    "
    if { $customer_can_use_old_credit_cards } {
        ns_puts "$credit_card_message_1
	$old_cards_to_choose_from
	$credit_card_message_2
	"
    }

    ns_puts "<table>
    <tr>
    <td>Credit card number:</td>
    <td><input type=text name=creditcard_number size=17></td>
    </tr>
    <tr>
    <td>Type:</td>
    <td>$ec_creditcard_widget</td>
    </tr>
    <tr>
    <td>Expires:</td>
    <td>$ec_expires_widget</td>
    <tr>
    <td>Billing zip code:</td>
    <td><input type=text name=billing_zip_code value=\"$zip_code\" size=5></td>
    </tr>
    </table>
    </blockquote>
    "
}

# Done with Tcl
%>

<center>
<input type=submit value="Continue">
</center>

</form>

</blockquote>
<ec_footer></ec_footer>

<ec_header>$page_title</ec_header>
<ec_navbar></ec_navbar>

<h2><%= $page_title %></h2>

<blockquote>

<%

# This page performs a number of different functions depending on how it's
# accessed.
# Therefore the content needs to be contained inside a Tcl "if statement".
# Here's the "if statement".  If you modify any of the text, make sure you
# put a backslash before any embedded quotation marks you add.

if { $page_function == "view" } {
    
    set page_contents "<form method=post action=\"shopping-cart-retrieve-3.tcl\">
    $hidden_form_variables
    <input type=submit name=submit value=\"Retrieve\">
    <input type=submit name=submit value=\"Discard\">
    </form>
    <center>
    Saved on $saved_date<p>
    <table border=0 cellspacing=0 cellpadding=5>
    $shopping_cart_items
    </table>
    </center>
    </form>
    "

    if { $product_counter == 0 } {
	append page_contents "Your Shopping Cart is empty."
    }

} elseif { $page_function == "retrieve" } {

    set page_contents "<form method=post action=\"shopping-cart-retrieve-3.tcl\">
    [export_form_vars order_id]
    You currently already have a shopping cart.  Would you like to merge your current shopping cart with the shopping cart you are retrieving, or should the shopping cart you're retrieving completely replace your current shopping cart?
    <p>

    <center>
    <input type=submit name=submit value=\"Merge\">
    <input type=submit name=submit value=\"Replace\">
    </center>

    </form>
    "
} elseif { $page_function == "discard" } {

    set page_contents "<form method=post action=\"shopping-cart-retrieve-3.tcl\">
    $hidden_form_variables
    If you discard this shopping cart, it will never be retrievable.  Are you sure you want to discard it?
    <p>
    <center>
    <input type=submit name=submit value=\"Discard\">
    <input type=submit name=submit value=\"Save it for Later\">
    </center>
    </form>
    "
}

# OK, that's all the Tcl.  Not too bad.  Just make sure that all embedded
# quotation marks have a backslash before them (\"), otherwise you'll get
# an error.

%>

<%= $page_contents %>

</blockquote>
<ec_footer></ec_footer>
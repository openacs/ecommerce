#  www/[ec_url_concat [ec_url] /admin]/shipping-costs/examples.tcl
ad_page_contract {

  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

set page_html "[ad_admin_header "Shipping Cost Examples"]

<h2>Shipping Cost Examples</h2>

[ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Shipping Costs"] "Some Examples"]

<hr>

<ul>

<li>Example 1: CD Store

<p>

  <ul>
  <li>What I want:
  I want to charge customers \$3.00 per order, and also an additional \$1.00 per CD.
  <p>
  However, I also sell some double CDs and some boxed sets, so those should have an additional shipping charge associated with them.
  <p>
  <li>What I fill in:
  I put in \"3.00\" as the Base Cost and \"1.00\" as the Default Amount Per Item.
  For each product that should have a shipping cost of more than \$1.00, 
  I have to make sure that I set its Shipping Price on the page where I
  enter or edit product information.
  </ul>

<p>

<li>Example 2: Furniture Store

<p>

  <ul>

  <li>What I want: I want to charge people 50 cents per pound of furniture
  that I ship them.

  <p>

  <li>What I fill in: I can leave the Base Cost blank (or set it to \"0\"),
    and then I put in \"0.50\" as the \"Weight Charge\".

  </ul>

<p>

<li>Example 3: Store with Many Different Kinds of Products

<p>

  <ul>
  <li>What I want: I want to charge people \$4.00 for each order and then
  an additional amount per item that is different for each product.

  <p>

  <li>What I fill in: Just the Base Cost as \"4.00\".  Leave everything
  else blank.  When I add new products to my store, I just have to make
  sure I fill in the \"Shipping Price\" field for each of them.

  </ul>

</ul>

[ad_admin_footer]
"

doc_return  200 text/html $page_html










ad_page_contract {

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    order_id:integer,notnull
    product_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

# In case they reload this page after completing the void process:

if { [db_string num_non_void_items_select "
    select count(*) 
    from ec_items 
    where order_id = :order_id 
    and product_id = :product_id
    and item_state <> 'void'"] == 0 } {
    ad_return_complaint 1 "
	<li>These items are already void; perhaps you are using an old form. <a href=\"one?[export_url_vars order_id]\">Return to the order.</a></li>"
    return
}

set n_items [db_string num_items_select "
    select count(*) 
    from ec_items
    where order_id = :order_id
    and product_id = :product_id"]

if { $n_items > 1 } {
    set item_or_items "Items"
} else {
    set item_or_items "Item"
}

doc_body_append "
    [ad_admin_header "Void $item_or_items"]

    <h2>Void $item_or_items</h2>
    
    [ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Orders"] [list "one?[export_url_vars order_id]" "One Order"] "$item_or_items"]

    <hr>
    <blockquote>
      <form method=post action=items-void-2>
        [export_form_vars order_id product_id]"

# We have to take care of some cases (hopefully #1, the simplest, will
# be most prevalent) different cases get different wording and cases
# 1-2 are functionally different than cases 3-4
# 1. There's only one item in this order with this product_id and it
#    hasn't shipped yet
# 2. There's only one item in this order with this product_id and it's
#    already shipped
# 3. More than one item in this order with this product_id and no
#    non-void items have already shipped
# 4. More than one item in this order with this product_id and at
#    least one non-void item has already shipped

if { $n_items == 1 } {

    # Cases 1 & 2 (only differ by a warning message) we assume it's
    # not void, otherwise they wouldn't have been given the link to
    # this page

    set item_state [db_string item_state_select "
	select item_state
	from ec_items 
	where order_id = :order_id
	and product_id = :product_id"]

    if { $item_state == "shipped" || $item_state == "arrived" || $item_state == "received_back" } {
	doc_body_append "
	    <p><font color=red>Warning:</font> our records show that this item has already
	      shipped, which means that the customer has already been charged for this
	      item. Voiding an item will not cause the customer's credit card to be
	      refunded (you can only do that by marking it \"received back\").</p>"
    }    

    db_foreach order_products_select "
	select i.item_id, i.item_state, p.product_name, i.price_name, i.price_charged
	from ec_items i, ec_products p
	where i.product_id = p.product_id
	and i.order_id = :order_id
	and i.product_id = :product_id" {
	
        doc_body_append "
	    <p>Please confirm that you want to void $product_name; $price_name: [ec_pretty_price $price_charged] $item_state</p>"
    }
} else {

    # Cases 3 & 4 (only differ by a warning message)

    set n_shipped_items [db_string num_shipped_items_select "
	select count(*) 
	from ec_items
	where order_id = :order_id 
	and product_id=:product_id
	and item_state in ('shipped','arrived','received_back')"]

    if { $n_shipped_items > 0 } {
	doc_body_append "
	    <p><font>Warning:</font> our records show that at least one of these
	      items has already shipped, which means that the customer has already
	      been charged (for shipped items only). Voiding an item will not cause
	      the customer's credit card to be refunded 
	      (you can only do that by marking it \"received back\").</p>"
    }
    doc_body_append "
	<p>Please check off the item(s) you wish to void.</p>
	<table>
	  <tr>
	    <th>Void Item</th>
            <th>Product</th>
	    <th>Item State</th>"

    db_foreach order_products_select "
	select i.item_id, i.item_state, p.product_name, i.price_name, i.price_charged
	from ec_items i, ec_products p
	where i.product_id = p.product_id
	and i.order_id = :order_id
	and i.product_id = :product_id" {
	
	doc_body_append "
	    <tr>
	      <td align=center>"
	if { $item_state == "void" } {
	    doc_body_append " (already void) "
	} else {
	    doc_body_append "<input type=\"checkbox\" name=\"item_id\" value=\"$item_id\">"
	}
	doc_body_append "
		  </td>
		  <td>$product_name; $price_name: [ec_pretty_price $price_charged]</td><td>$item_state</td>
		</tr>"
    }
    doc_body_append "</table>"
}

doc_body_append "
    </blockquote>
    <center>
      <input type=submit value=\"Confirm\">
    </center>
    </form>
    [ad_admin_footer]"

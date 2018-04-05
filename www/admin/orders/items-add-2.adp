<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>


<p> Note: the customer's credit card is not going to be reauthorized when you add this item to the order 
(their card was already found to be valid when they placed the initial order).
They will, as usual, be automatically billed for this item when it ships.
If the customer's credit limit is in question, just make a test authorization offline.</p>
<h3>Product(s) that match your search.</h3>
<if @product_counter@ gt 0>
	    <ul>
    @products_select_html;noquote@
       </ul>
</if><else>
	<p>No matching products were found.</p>
</else>

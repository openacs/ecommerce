<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<if @price@ not nil>
	<h3>Regular Price</h3>
	<blockquote>
	  Regular: @price@
	</blockquote>
</if>

<h3>Current Sale Prices</h3>
<if @sale_price_counter@ eq 0>
<p>There are no current sale prices.</p>
</if><else>
 <ul>
  @current_sales_select_html;noquote@
 </ul>
</else>


<h3>Add a Sale Price</h3>

<blockquote>
<form method=post action=sale-price-add>
@export_form_vars_html;noquote@

<table>
<tr>
<td>Sale Price</td>
<td><input type=text name=sale_price size=6> (in @currency@)</td>
</tr>
<tr>
<td>Name</td>
<td><input type=text name=sale_name size=15> (like Special Offer or Introductory Price or Sale Price)</td>
</tr>
<tr>
<td>Sale Begins</td>
<td>@sale_begins_widget_html;noquote@</td>
</tr>
<tr>
<td>Sale Ends</td>
<td>@sale_ends_widget_html;noquote@</td>
</tr>
<tr>
<td valign=top>Offer Code</td>
<td valign=top><input type=radio name="offer_code_needed" value="no" checked> None needed<br>
<input type=radio name="offer_code_needed" value="yes_supplied"> Require this code: 
<input type=text name="offer_code" size=10 maxlength=20><br>
<input type=radio name="offer_code_needed" value="yes_generate"> Please generate a code
</td>
</tr>
</table>

<br>

<center>
<input type=submit value="Add">
</center>

</form>
<p>To let customers take advantage of a sale price that requires an offer_code, send them to the URL
of the product display page with <code>&amp;offer_code=<i>offer_code</i></code>
appended to the URL.</p>

</blockquote>

<br>

<h3>Old or Yet-to-Come Sale Prices</h3>

<if @nc_sale_price_counter@ eq 0>
<p>There are no non-current sale prices.</p>
</if><else>
 <ul>
  @non_current_sales_select_html;noquote@
 </ul>
</else>

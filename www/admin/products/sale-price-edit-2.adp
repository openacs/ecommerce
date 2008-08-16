<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

    <table>
	<tr>
	  <td>Sale Price</td>
	  <td>@sale_price_html@</td>
	</tr>
	<tr>
	  <td>Name</td>
	  <td>@sale_name@</td>
	</tr>
	<tr>
	  <td>Sale Begins</td>
	  <td>@sale_begins_html;noquote@</td>
	</tr>
	<tr>
	  <td>Sale Ends</td>
	  <td>@sale_ends_html;noquote@</td>
	</tr>
	<tr>
	  <td>Offer Code</td>
	  <td>@offer_code_html@</td>
	</tr>
    </table>

    <form method=post action=sale-price-edit-3>
      @export_form_vars_html;noquote@
      <input type=hidden name=sale_begins value="@sale_begins_text@">
      <input type=hidden name=sale_ends value="@sale_ends_text@">
      <center>
	<input type=submit value="Confirm">
      </center>
    </form>

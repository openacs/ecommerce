<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<form method=post action=sale-price-edit-2>
@export_form_vars_html;noquote@
    <table>
	<tr>
	  <td>Sale Price</td>
	  <td><input type=text name=sale_price size=6 value="@sale_price;noquote@"> (in @currency_html@)</td>
	</tr>
	<tr>
	  <td>Name</td>
	  <td><input type=text name=sale_name size=35 maxlength=30 value="@sale_name@"> (like Special Offer or Introductory Price or Sale Price)</td>
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
	  <td><input type=radio name="offer_code_needed" value="no" @offer_code_none_html@> None needed<br>
	    <input type=radio name="offer_code_needed" value="yes_supplied" @offer_code_required_html@> Require this code: 
	    <input type=text name="offer_code" size=10 maxlength=20 value="@offer_code@"><br>
	    <input type=radio name="offer_code_needed" value="yes_generate"> Please generate a @offer_code_new_html@ code
	  </td>
	</tr>
    </table>

    <center>
      <input type=submit value="Submit">
    </center>
</form>

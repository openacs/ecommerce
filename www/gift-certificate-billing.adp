<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <property name="current_location">gift-certificate</property>

<include src="/packages/ecommerce/lib/toolbar">
<include src="/packages/ecommerce/lib/searchbar">

<blockquote>

  <p><b>Please enter your billing address.</b></p>

  <blockquote>
    <table>
      <multiple name="addresses">
	<if @addresses.rownum@ odd>
	  <tr>
	</if>
	<else>
	  <tr bgcolor="#eeeeee">
	</else>
	<td>
	  @addresses.formatted;noquote@
	</td>
	<td>
	  <table>
	    <tr>
	      <td>
		<form method="post" action="gift-certificate-order-3">
		  @addresses.use;noquote@
		  <input type="submit" value="Use"></input>
		</form>
	      </td>
	      <td>
		<form method="post" action="address">
		  @addresses.edit;noquote@
		  <input type="submit" value="Edit"></input>
		</form>
	      </td>
	      <td>
		<form method="post" action="delete-address">
		  @addresses.delete;noquote@
		  <input type="submit" value="Delete"></input>
		</form>
	      </td>
	    </tr>
	  </table>
	</td>
      </tr>
	<tr>
	  <td>
	    &nbsp;
	  </td>
	</tr>
      </multiple>
    </table>
  </blockquote>

  <table>
    <tr>
      <td>
	<form method="post" action="address">
	  @hidden_form_vars;noquote@
	  <input type="submit" value="Enter a new U.S. address">
	</form>
      </td>
      <td>
	or
      </td>
      <td>
	<form method="post" action="address">
	  @hidden_form_vars;noquote@
	  <input type="submit" value="Enter a new INTERNATIONAL address">
	</form>
      </td>
    </tr>
  </table>

</blockquote>

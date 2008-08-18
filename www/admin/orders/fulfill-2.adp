<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

    <form method=post action=fulfill-3>
@export_form_vars_html;noquote@
    <input type=hidden name=shipment_date value="@temp_shipment_date@">
    <input type=hidden name=expected_arrival_date value="@temp_expected_arrival_date@">

    <center>
      <input type=submit value="Confirm">
    </center>

<p>Item(s):</p>
    <ul>
       @items_to_print;noquote@
   </ul>

<if @shippable_p false>
 <p>Pickup date: @temp_shipment_date_html;noquote@</p>
</if><else>
 <p>Shipment information:</p>
	<ul>
	  <li>Shipment date: @shipment_date_html;noquote@</li>
	</ul>

	<p>Ship to:</p>

	<blockquote>
      @shipment_to_html;noquote@
	</blockquote>
</else>

<center>
  <input type=submit value="Confirm">
</center>
</form>

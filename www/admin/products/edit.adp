<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>
<p>
All fields are optional except Product Name.
</p>
<form enctype=multipart/form-data method=post action=edit-2>
@export_form_vars_html;noquote@
<table>
<tr>
<td>Product Name</td>
<td colspan=2><input type=text name=product_name size=30 value="@product_name@"></td>
</tr>
<tr>
<td>SKU</td>
<td><input type=text name=sku size=10 value="@sku@"></td>
<td>It's not necessary to include a SKU because the system generates its own
internal product_id to uniquely distinguish products.</td>
</tr>
<tr>
<td>Product Category</td>
<td>@product_category_html;noquote@</td>
<td>Choose as many categories as you like.  The product will
be displayed on the web site in each of the categories you select.</td>
</tr>
<if @multiple_retailers_p@ true>
     @stock_status_html;noquote@
</if><else>
<tr>
    <td>Stock Status</td>
    <td colspan=2>@stock_status_html;noquote@</td>
</tr>
<tr>
    <td>Regular Price</td>
    <td><input type=text size=6 name=price value="@price@"></td>
    <td>All prices are in @currency@.  The price should
    be written as a decimal number (no special characters like $).
    </tr>
<tr>
    <td>Shipping Price</td>
    <td><input type=text size=6 name=shipping value="@shipping@"></td>
    <td rowspan=3 valign=top>The "Shipping Price", "Shipping Price - Additional", and "Weight" fields
    may or may not be applicable, depending on the 
    <a href="../shipping-costs/">shipping rules</a> you have set up for
    your ecommerce system.</td>
    </tr>
    <tr>
    <td>Shipping Price - Additional per item if ordering more than 1 (leave blank if same as Shipping Price above)</td>
    <td><input type=text size=6 name=shipping_additional value="@shipping_additional@"></td>
    </tr>

</else>
<tr>
<td>One-Line Description</td>
<td colspan=2><input type=text name=one_line_description size=60 value="@one_line_description@"></td>
</tr>
<tr>
<td>Additional Descriptive Text</td>
<td colspan=2><textarea wrap rows=6 cols=60 name=detailed_description>@detailed_description@</textarea></td>
</tr>
<tr>
<td><p>Search Keywords</p><p>
Data from Product's Name, One Line Description, and Other Detailed Description
 are automatically included in product searches. No need to repeat as keywords.</p></td>
<td colspan=2><textarea wrap rows=2 cols=60 name=search_keywords>@search_keywords@</textarea></td>
</tr>
<tr>
<td>Picture</td>
<td><input type=file size=10 name=upload_file>
<if @thumbnail@ exists>
<br>Your current picture is:<br>@thumbnail;noquote@
</td>
<td>This picture (.gif or .jpg format) can be as large as you like.  A thumbnail will be automatically generated.  Note that file uploading doesn't work with Internet Explorer 3.0.</td>
</tr>
<tr>
<td>Color Choices</td>
<td><input type=text name=color_list size=40 value="@color_list@"></td>
<td>This should be a comma-separated list of colors the user is allowed to choose from
when ordering.  If there are no choices, leave this blank.</td>
</tr>
<tr>
<td>Size Choices</td>
<td><input type=text name=size_list size=40 value="@size_list@"></td>
<td>This should be a comma-separated list of sizes the user is allowed to choose from
when ordering.  If there are no choices, leave this blank.</td>
</tr>
<tr>
<td>Style Choices</td>
<td><input type=text name=style_list size=40 value="@style_list@"></td>
<td>This should be a comma-separated list of styles the user is allowed to choose from
when ordering.  If there are no choices, leave this blank.</td>
</tr>
<tr>
<td>Email on Purchase</td>
<td><input type=text name=email_on_purchase_list size=40 value="@email_on_purchase_list@"></td>
<td>This should be a comma-separated list of recipients to notify when a purchase is made. If you do not wish email to be sent, leave this blank.</td>
</tr>
<tr>
<td>URL where the consumer can get more info on the product</td>

<td colspan=2><input type=text name=url size=50 value="@url@"></td>
</tr>
<tr>
<td>Is this product shippable?</td>
<td><input type=radio name=no_shipping_avail_p value="f" @no_shipping_avail_p_html@>Yes
&nbsp;&nbsp;
<input type=radio name=no_shipping_avail_p value="t" @shipping_avail_p_html@>No
</td>
<td>You might choose "No" if this product is actually a service.</td>
</tr>
<tr>
<td>Should this product be displayed when the user does a search?</td>
<td><input type=radio name=present_p value="t" @present_p_html@>Yes
&nbsp;&nbsp;
<input type=radio name=present_p value="f" @no_present_p_html@>No
</td>
<td>You might choose "No" if this product is part of a series.</td>
</tr>
<tr>
<td>When does this product become available for purchase?</td>
<td>@available_date_html;noquote@</td>
</tr>
<tr>
<td>Weight (@weight_units_html@)</td>
<td><input type=text size=3 name=weight value="@weight@"></td>
</tr>
<tr>
<td>Template</td>
<td>@template_widget_html;noquote@</td>
<td>Select a template to use when displaying this product. If none is
selected, the product will be displayed with the system default template.</td>
</tr>
</table>

<p>
<if @n_user_classes@ gt 0>
<h3>Special Prices for User Classes</h3>
    <br/>
    <table noborder>
@n_user_classes_html;noquote@
    </table>
</if>

<if @n_custom_product_fields@ gt 0>
<h3>Custom Fields</h3>
    <p>
    <table noborder>
@custom_product_fields_html;noquote@
    </table>
</if>
<center>
<input type=submit value="Continue">
</center>
</form>

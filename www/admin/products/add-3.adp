<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<h3>Please confirm that the information below is correct:</h3>
<form method=post action=add-4>
<center>
<input type=submit value="Confirm">
</center>
<blockquote>
@linked_thumbnail;noquote@
<table noborder>
<tr><td align="right">
Product Name:
</td>
<td>
@product_name;noquote@
</td>
</tr>
<tr><td align="right">
SKU:
</td>
<td>
@sku@
</td>
</tr>
<tr><td align="right">
Categorization:
</td>
<td>
@categorization_html;noquote@
</td>
</tr>
<if @multiple_retailers_p;literal@ true>


</if><else>
<tr>
    <td align="right">
    Stock Status:
    </td>
    <td>@stock_status_html;noquote@
</td>
    </tr>
<tr>
    <td align="right">
    Regular Price:
    </td>
    <td>
    @price_html@
    </td>
    </tr>
    <tr>
    <td align="right">
    Shipping Price
    </td>
    <td>
@shipping_html@
    </td>
    </tr>
    <tr>
    <td align="right">
    Shipping - Additional
    </td>
    <td>

@shipping_additional_html@
    </td>
    </tr>

</else>
<tr><td align="right">
One-Line Description:
</td>
<td>
@one_line_description_html;noquote@
</td>
</tr>
<tr><td align="right">
Additional Descriptive Text:
</td>
<td>
@detailed_description_html;noquote@
</td>
</tr>
<tr><td align="right">
Search Keywords:
</td>
<td>
@search_keywords_html@
</td>
</tr>
<tr><td align="right">
Color Choices:
</td>
<td>
@color_list_html;noquote@
</td>
</tr>
<tr><td align="right">
Size Choices:
</td>
<td>
@size_list_html;noquote@
</td>
</tr>
<tr><td align="right">
Style Choices:
</td>
<td>
@style_list_html;noquote@
</td>
</tr>
<tr><td align="right">
Email On Purchase:
</td>
<td>
@email_on_purchase_list_html@
</td>
</tr>
<tr><td align="right">
URL:
</td>
<td>
@url_html@
</td>
</tr>
<tr><td align="right">
Is this product shippable?
</td>
<td>
@no_shipping_avail_p_html@
</td>
</tr>
<tr><td align="right">
Display this product when user does a search?
</td>
<td>
@present_p_html@
</td>
</tr>
<tr><td align="right">
Weight
</td>
<td>
@weight_html@
</td>
</tr>
@custom_product_fields_select_html;noquote@
<tr><td align="right">
Template
</td>
<td>
@template_html;noquote@
</td>
</tr>
</table>
</blockquote>
<p>
@export_form_vars_html;noquote@

@custom_fields_select_html;noquote@

@user_class_select_html;noquote@
<center>
<input type=submit value="Confirm">
</center>
</form>


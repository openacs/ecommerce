<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<h3>Please confirm that the information below is correct:</h3>

<form method=post action=edit-3>
<center>
<input type=submit value="Confirm">
</center>
<blockquote>
@linked_thumbnail;noquote@
<table noborder>
<tr>
<td>
Product Name:
</td>
<td>
@product_name@
</td>
</tr>
<tr>
<td>
SKU
</td>
<td>
@sku@
</td>
</tr>
<tr>
<td>
Categorization:
</td>
<td>
@categorization_html;noquote@
</td>
</tr>
<if @multiple_retailers_p@ true>
@stock_status_html;noquote@
</if><else>
   <tr>
    <td>
    Stock Status:
    </td>
    <td>
@stock_status_html;noquote@
</td>
    </tr>
<tr>
    <td>
    Regular Price:
    </td>
    <td>
    @regular_price@
    </td>
    </tr>
<tr>
    <td>
    Shipping Price
    </td>
    <td>
    @shipping_price@
    </td>
    </tr>
    <tr>
    <td>
    Shipping - Additional
    </td>
    <td>
    @shipping_additional_price@
    </td>
    </tr>
  @user_classes_select_html;noquote@
</else>

<tr>
<td>
One-Line Description:
</td>
<td>
@one_line_description_html;noquote@
</td>
</tr>
<tr>
<td>
Additional Descriptive Text:
</td>
<td>
@detailed_description_html;noquote@
</td>
</tr>
<tr>
<td>
Search Keywords:
</td>
<td>
@search_keywords_html@
</td>
</tr>
<tr>
<td>
Color Choices:
</td>
<td>
@color_list_html;noquote@
</td>
</tr>
<tr>
<td>
Size Choices:
</td>
<td>
@size_list_html;noquote@
</td>
</tr>
<tr>
<td>
Style Choices:
</td>
<td>
@style_list_html;noquote@
</td>
</tr>
<tr>
<td>
Email on Purchase:
</td>
<td>
@email_on_purchase_list_html;noquote@
</td>
</tr>
<tr>
<td>
URL:
</td>
<td>
@url_html;noquote@
</td>
</tr>
<tr>
<td>
Is this product shippable?
</td>
<td>
@no_shipping_avail_p_html;noquote@
</td>
</tr>
<tr>
<td>
Display this product when user does a search?
</td>
<td>
@present_p_html;noquote@
</td>
</tr>
<tr>
<td>
Weight
</td>
<td>
@weight_html;noquote@
</td>
</tr>

@custom_fields_select_html;noquote@

<tr>
<td>
Template
</td>
<td>
@template_name_select_html;noquote@
</td>
</tr>
<tr>
<td>
Available Date
</td>
<td>
@available_date_html;noquote@
</td>
</tr>
</table>
</blockquote>
<p>
@export_form_vars_html;noquote@
<center>
<input type=submit value="Confirm">
</center>
</form>

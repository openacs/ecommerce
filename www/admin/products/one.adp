<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

    <ul>
      <li>Professional Reviews:  <a href="reviews?@export_product_id_var;noquote@">@product_review_anchor@</a></Li>
      <li>Customer Reviews: @customer_reviews_link;noquote@</li>
       <li>Cross-selling Links:  <a href="link?@export_product_id_var;noquote@">@n_links_to;noquote@
      to; @n_links_from;noquote@ from</a></li>
    </ul>

    <h3>Complete Record</h3>
       <a href="edit?@export_product_id_var;noquote@">Edit This Item</a>

    <blockquote>
<if @active_p@ false>
<p><b>This product is discontinued.</b></p>
</if><else>

@linked_thumbnail_html;noquote@

<table noborder>
	<tr>
	  <td>
	    Product ID:
	  </td>
	  <td>
	    @product_id@
	  </td>
	</tr>
	<tr>
	  <td>
	    Product Name:
	  </td>
	  <td>
	    @product_name;noquote@
	  </td>
	</tr>
	<tr>
	  <td>
	    SKU:
	  </td>
	  <td>
	    @sku_html@
	  </td>
	</tr>
    @price_row;noquote@
    @no_shipping_avail_p_row;noquote@
    @active_p_row;noquote@
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
<ul>
<li><a href="offers?@export_product_id_name_var;noquote@">Retailer Offers</a></li>
</ul>

  </if><else>
	<tr>
	  <td>Stock Status:</td>
	  <td>@stock_status_html;noquote@
</td></tr>

	<tr>
	  <td>Shipping Price:</td>
	  <td>@shipping_html;noquote@</td>
	</tr>
	<tr>
	   <td>Shipping - Additional:</td>
	  <td>@shipping_additional_html;noquote@</td>
	</tr>

@user_class_select_html;noquote@




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
    Display this product when user does a search?
  </td>
  <td>
    @present_p_html@ (<a href="toggle-present-p?@export_product_id_var;noquote@">toggle</a>)
  </td>
</tr>

    <tr>
      <td>Weight:</td>
      <td>@weight_html;noquote@</td>
    </tr>

@custom_fields_iteration_html;noquote@

<tr>
  <td>
    Template:
  </td>
  <td>
    @template_html;noquote@
  </td>
</tr>
<tr>
  <td>
    Date Added:
  </td>
  <td>
    @date_added_html;noquote@
  </td>
</tr>
<tr>
  <td>
    Date Available:
  </td>
  <td>
    @date_available_html;noquote@
  </td>
</tr>
<tr>
  <td>
    Directory Name (where image &amp; other product info is kept):
  </td>
  <td>
    @dirname_cell;noquote@
  </td>
</tr>
</table>


</blockquote>
<ul>
    <li><a href="edit?@export_product_id_var;noquote@">Edit</a><br></li>
    <li><a href="@audit_url_html;noquote@">Audit Trail</a></li>    
    <li><a href="delete?@export_product_id_name_var;noquote@">Delete</a></li>
</ul>
</else>


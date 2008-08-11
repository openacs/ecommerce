<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

<include src="/packages/ecommerce/lib/toolbar">
<include src="/packages/ecommerce/lib/searchbar">


<if @subcategories:rowcount@ true or @recommendations:rowcount@>
  <table width="90%">
    <tr valign="top">
      <if @subcategories:rowcount@ true>
        <td width="50%">
	  <h4>@category_name@ &gt; subcategories</h4>

      <multiple name="subcategories">
      &gt;  <a href="@subcategories.url@">@subcategories.name@</a><br>
      </multiple>
	 	  
        </td>
      </if>
      <if @recommendations:rowcount@ >
        <td>
	  <h4>We recommend:</h4>
    <table width="100%">
    <multiple name="recommendations">
    <tr>
	    <td valign=top>
<if @recommendations.thumbnail_url@ not nil>
<a href="@recommendations.product_url@"><img src="@recommendations.thumbnail_url@" height="@recommendations.thumbnail_height@" width="@recommendations.thumbnail_width@"></a>
</if>
    </td>
	    <td valign=top><a href="@recommendations.product_url@">@recommendations.product_name@</a>
	      <p>@recommendations.recommendation_text;noquote@</p>
	    </td>
	    <td valign=top align=right>@recommendations.price_line;noquote@</td>
    </tr>
    </multiple>
        </table>
        </td>
     </if>
    </tr>
  </table>      
</if>

  <if @products:rowcount@ gt 0>
  <h4>@category_name@ items:</h4>

<table width="90%">
<multiple name="products">
<if @products.rownum@ ge @start@ and @products.rownum@ le @end@>
	      <tr valign=top>
	        <td rowspan=2>
<if @products.thumbnail_url@ not nil>
<a href="product?product_id=@products.product_id@"><img src="@products.thumbnail_url@" height="@products.thumbnail_height@" width="@products.thumbnail_width@"></a>
</if>
</td>
	        <td colspan=2><a href="product?product_id=@products.product_id@"><b>@products.product_name@</b></a></td>
	      </tr>
	      <tr valign=top>
		<td>@products.one_line_description;noquote@</td>
		<td align=right>@products.price_line;noquote@</td>
	      </tr>
</if>
</multiple>
</table>

<if @prev_url@ defined>
<a href="@prev_url;noquote@">Previous @how_many@</a>

<if @next_url@ defined>|</if>
</if>

<if @next_url@ defined>
<a href="@next_url;noquote@">Next @how_many_next@</a>
</if>
</if>

  <if @products:rowcount@ eq 0 and @subcategories:rowcount@ false>
	There are currently no items listed in this category.&nbsp;&nbsp;Please check back often for updates.
  </if>

  
<p align="right"><a href="mailing-list-add?category_id=@the_category_id@">Add yourself to the @the_category_name@ mailing list!</a></p>

<master>
  <property name="title">@subcategory_name;noquote@</property>
  <property name="context_bar">@context_bar;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <property name="show_toolbar_p">t</property>

<blockquote>
<if @subcategories:rowcount@ or @recommendations:rowcount@>
  <table width="90%">
    <tr valign="top">
      <if @subcategories:rowcount@ >
        <td width="50%">
	  <h4>Browse:</h4>
	  <ul>
      <multiple name="subcategories">
      &gt;  <a href="@subcategories.url@">@subcategories.name@</a><br>
      </multiple>

	  </ul>
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
  <h4><a href="@category_url;noquote@">@category_name@</a> &gt; @subcategory_name@ products:</h4>

<table width="90%">
<multiple name="products">
<if @products.rownum@ ge @start@ and @products.rownum@ le @end@>
	      <tr valign=top>
	        <td rowspan=2>
<if @products.thumbnail_url@ not nil>
<a href="product?product_id=@products.product_id@" border="0"><img src="@products.thumbnail_url@" height="@products.thumbnail_height@" width="@products.thumbnail_width@"></a>
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


</blockquote>

<p><a href="<%= mailing-list-add?category_id=@category_id@&subcategory_id=@subcategory_id@ %>">Add yourself to the @the_category_name@ mailing list!</a></p>

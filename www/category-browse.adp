<master>
  <property name="title">@the_category_name;noquote@</property>
  <property name="context_bar">@context_bar;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <property name="show_toolbar_p">t</property>

<if @subcategories_p@ true or @recommendations@>
  <table width="90%">
    <tr valign="top">
      <if @subcategories_p@ true>
        <td width="50%">
	  <h4>@category_name@ &gt; subcategories</h4>

      <if subcategories_p true>
      <multiple name="subcategories">
      &gt;  <a href="@subcategories.url@">@subcategories.name@</a><br>
      </multiple>
      </if>
	 	  
        </td>
      </if>
      <if @recommendations@ >
        <td>
	  <h4>We recommend:</h4>
	  @recommendations;noquote@
       
        </td>
     </if>
    </tr>
  </table>      
</if>

  <if @count@ gt 0>
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

  <if @count@ eq 0 and @subcategories_p@ false>
	There are currently no items listed in this category.&nbsp;&nbsp;Please check back often for updates.
  </if>

  
<p align="right"><a href="mailing-list-add?category_id=@the_category_id@">Add yourself to the @the_category_name@ mailing list!</a></p>

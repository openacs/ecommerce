<master>
  <property name="title">@the_category_name;noquote@</property>
  <property name="context_bar">@context_bar;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <property name="show_toolbar_p">t</property>

<if @subcategories@ or @recommendations@>
  <table width="90%">
    <tr valign="top">
      <if @subcategories@ >
        <td width="50%">
	  <h4>@category_name@ &gt; subcategories</h4>
	  
	    @subcategories;noquote@
	  
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
  @products;noquote@

  @prev_link;noquote@ @separator;noquote@ @next_link;noquote@
  </if>

  
<p align="right"><a href="mailing-list-add?category_id=@the_category_id@">Add yourself to the @the_category_name@ mailing list!</a></p>

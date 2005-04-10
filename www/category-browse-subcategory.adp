<master>
  <property name="title">@subcategory_name;noquote@</property>
  <property name="context_bar">@context_bar;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <property name="show_toolbar_p">t</property>

<blockquote>
<if @subcategories@ or @recommendations@>
  <table width="90%">
    <tr valign="top">
      <if @subcategories@ >
        <td width="50%">
	  <h4>Browse:</h4>
	  <ul>
	    @subcategories@
	  </ul>
        </td>
      </if>
      <if @recommendations@ >
        <td>
	  <h4>We recommend:</h4>
	  @recommendations@
        </td>
     </if>
    </tr>
  </table>      
</if>
  <h4><a href="@category_url@">@category_name@</a> &gt; @subcategory_name@ products:</h4>
  @products;noquote@

  @prev_link;noquote@ @separator@ @next_link;noquote@
</blockquote>

<p><a href="<%= mailing-list-add?category_id=@category_id@&subcategory_id=@subcategory_id@ %>">Add yourself to the @the_category_name@ mailing list!</a></p>

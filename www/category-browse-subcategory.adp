<master>
  <property name="title">@subcategory_name@</property>
  <property name="context_bar">@context_bar@</property>
  <property name="signatory">@ec_system_owner@</property>

  <include src="toolbar">

<blockquote>
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

  <h4><a href="category-browse?category_id=@the_category_id@">@category_name@</a> > @subcategory_name@ products:</h4>
  @products@

  @prev_link@ @separator@ @next_link@
</blockquote>

<p><a href="mailing-list-add?category_id= @category_id@&subcategory_id= @subcategory_id@">Add yourself to the @the_category_name@ mailing list!</a></p>

<master>
  <property name="title">@subsubcategory_name;noquote@</property>
  <property name="context_bar">@context_bar;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <property name="show_toolbar_p">t</property>

<blockquote>
  <table width="90%">
    <tr valign="top">
      <if @recommendations@ >
        <td>
	  <h4>We recommend:</h4>
	  @recommendations;noquote@
        </td>
     </if>
    </tr>
  </table>      

  <h4><a href="category-browse?category_id=@the_category_id@">@category_name@</a> > <a href="category-browse-subcategory?category_id=@the_category_id@&subcategory_id=@subcategory_id@">@subcategory_name@</a> > @subsubcategory_name@ products:</h4>
  @products@

  @prev_link;noquote@ @separator@ @next_link;noquote@
</blockquote>

<p><a href="mailing-list-add?category_id=@the_category_id@&subcategory_id=@subcategory_id@&subsubcategory_id=@subsubcategory_id@">Add yourself to the @the_category_name@ mailing list!</a></p>

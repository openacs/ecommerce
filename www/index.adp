<master>
<property name="head">
  <meta name="description" content="Example OpenACS ecommerce catalog">
  <meta name="keywords" content="">
  <meta name="Robots" content="INDEX,FOLLOW">
</property>

<include src="/packages/ecommerce/lib/toolbar">
<include src="/packages/ecommerce/lib/searchbar">

    <blockquote>
      <if @user_is_logged_on@ true>
	Welcome back @user_name@!&nbsp;&nbsp;&nbsp;If you're not @user_name@, click <a href="@register_url@">here</a>
      </if>
      <else>
	Welcome!
      </else>

      <include src="browse-categories">

      <if @recommendations:rowcount@>
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
      </if>

      <if @products@>
	<h4>Products:</h4>
	@products;noquote@

      @prev_link;noquote@ @separator@ @next_link;noquote@
      </if>
    </blockquote>

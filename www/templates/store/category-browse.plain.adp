<ec_header>$the_category_name</ec_header>
<ec_navbar>$the_category_id</ec_navbar>

<blockquote>


<p align=center>
<b><%= $the_category_name %></b>
<p>

<table width=90%>
  <tr valign=top>
    <td width=50%>
      <b>Browse</b>
      <ul>
         <%= $subcategories %>
      </ul>
    </td>
    <td>
      <%= $recommendations %>
    </td>
  </tr>
</table>      

  <%= $products %>

  <%= $prev_link %> <%= $separator %> <%= $next_link %>
</blockquote>

<p>

<a href="mailing-list-add?category_id=<%= $the_category_id %>">Add yourself to the <%= $the_category_name %> mailing list!</a>

</blockquote>

<ec_footer></ec_footer>

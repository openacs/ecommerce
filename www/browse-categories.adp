<h4>Browse</h4>

<table>
  <tbody>
    <grid name="categories" cols="3">

      <if @categories.col@ eq 1>
	<tr>
      </if>

      <td>
	<if @categories.rownum@ le @categories:rowcount@>
	  <ul>
	    <li><a href="@categories.url@" title="Browse @categories.name@">@categories.name@</a></li>
	  </ul>
	</if>
	<else>
	  <!-- Placeholder to retain cell formatting -->
	  &nbsp;
	</else>
      </td>

      <if @categories.col@ eq "3">
      </tr>
      </if>

    </grid>
  </tbody>
</table>

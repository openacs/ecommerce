<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<ul>
<li>Product Name:  @product_name;noquote@
</ul>

<h3>Current Reviews</h3>

<if @review_counter@ gt 0>
<ul>
@product_reviews_select_html;noquote@
</ul>
</if><else>
<p>There are no current reviews.</p>
</else>

<h3>Add a Review</h3>

<blockquote>
<form method=post action=review-add>
@export_form_vars_html;noquote@

<table cellspacing=10>
<tr>
<td valign=top>
Publication
</td>
<td>
<input type=text name=publication size=20>
</td>
</tr>
<tr>
<td>
Reviewed By
</td>
<td>
<input type=text name=author_name size=20>
</td>
</tr>
<tr>
<td>
Reviewed On
</td>
<td>
@review_date_html;noquote@
</td>
</tr>
<tr>
<td>
Display on web site?
</td>
<td>
<input type=radio name=display_p value="t" checked>Yes &nbsp;
<input type=radio name=display_p value="f">No
</td>
</tr>
<tr>
<td valign=top>
Review<br>
(HTML format)
</td>
<td valign=top>
<textarea name=review rows=10 cols=50 wrap=soft></textarea>
</td>
</tr>
</table>

<br>

<center>
<input type=submit value="Add">
</center>
</form>
</blockquote>

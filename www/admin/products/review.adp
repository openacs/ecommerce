<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<h3>The Review</h3>
<blockquote>
<table>
<tr>
<td>Summary</td>
<td>@summary_review@</td>
</tr>
<tr>
<td>Display on web site?</td>
<td>@display_p_html;noquote@</td>
</tr>
<tr>
<td>Review</td>
<td>@review@</td>
</tr>
</table>
</blockquote>

<br>

<h3>Edit this Review</h3>

<blockquote>
<form method=post action=review-edit>
@export_form_vars_html;noquote@
<table>
<tr>
<td>
Publication
</td>
<td>
<input type=text name=publication size=20 value="@publication@">
</td>
</tr>
<tr>
<td>
Reviewed By
</td>
<td>
<input type=text name=author_name size=20 value="@author_name@">
</td>
</tr>
<tr>
<td>
Reviewed On
</td>
<td>
</td>
</tr>
<tr>
<td>
Display on web site?
</td>
<td>
</td>
</tr>
<tr>
<td>
Review<br>
(HTML format)
</td>
<td>
<textarea name=review rows=10 cols=50 wrap>@review@</textarea>
</td>
</tr>
</table>

<br>

<center>
<input type=submit value="Edit">
</center>
</form>
</blockquote>

<h3>Audit Review</h3>

<ul>
<li><a href="@audit_url_html;noquote@">audit trail</a></li>
</ul>


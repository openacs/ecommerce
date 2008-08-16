<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<table>
<tr>
<td>Summary</td>
<td>@review_summary_html;noquote@</td>
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
<form method=post action=review-add-2>
@export_form_review_html;noquote@
<input type=hidden name=review_date value="@review_date_html@">

<center>
<input type=submit value="Confirm">
</center>
</form>

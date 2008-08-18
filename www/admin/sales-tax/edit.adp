<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>
Please specify the sales tax rates below for each state listed and whether tax
is charged on shipping in that state:
</p>

<form method=post action=edit-2>
  @export_form_vars_html;noquote@
<ul>
@usps_abbrev_list_html;noquote@
</ul>
<center>
  <input type=submit value="Submit">
</center>
</form>

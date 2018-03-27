<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>This page will let you see all changes to one table of the
@system_name@ database over a specified period of time. <b>It is
recommended that you start with a narrow time window and expand as
needed. Some tables can become very large.</b></p>

<form method=post action="audit-table">
@export_form_vars_html;noquote@
<ul>
@table_and_id_html;noquote@
 <li>When do you want to audit back to: (Leave blank to start at the beginning of the table's history.)<br>
    @start_point_html;noquote@</li>
 <li>When do you want to audit up to:<br>
    @end_point_html;noquote@</li>
</ul>

<center>
<p><b>Note: if the table is very large, this may take a while.</b><br>
<input type=submit value=Audit></p>
</center>
</form>

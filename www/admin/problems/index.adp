<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<if @display_all@ nil>
  <p><b>Unresolved Problems</b> (@unresolved_problem_count@) | 
  <a href="index?display_all=true">All Problems</a> (@problem_count@)</p>
</if><else>
  <p><a href="index">Unresolved Problems</a> (@unresolved_problem_count@) | 
  <b>All Problems</b> (@problem_count@)</p>
</else>

<if problem_count gt 0>
<ul>
  @problem_select_html;noquote@
</ul>
</if><else>
  <p>No problems reported.</p>
</else>

<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<if @count@ gt 0>
 <ul>
  @canned_responses_html;noquote@
 </ul>
</if><else>
<p>No canned (prepared) responses found.</p>
</else>
<p><a href="canned-response-add">Add a new prepared response</a>.</p>

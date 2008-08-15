<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

@doc_body;noquote@

<if @serious_errors@ false>
<p>Successfully imported @success_count@ product 
<if @success_count@ eq 1>
image and thumbnail 
</if><else>
images and thumbnails 
</else>
out of @count_html@.</p>
</if>

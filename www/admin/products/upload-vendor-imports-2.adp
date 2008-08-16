<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<if @serious_errors@ eq 0>
  @doc_body;noquote@
  <p>Successfully imported @success_count@ @product_string@ out of @line_count@.
  See server log for details.
  </p>
</if><else>
  <p>@doc_body;noquote@</p>
</else>

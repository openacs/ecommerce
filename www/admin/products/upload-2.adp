<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<if @serious_errors@ true>
@error_message@
</if><else>

@doc_body;noquote@
<p>Successfully loaded @success_count@ @product_string@ out of @total_lines@.</p>

</else>

<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<if @review_count@ gt 0>
  <ul>
    @doc_body;noquote@
  </ul>
</if><else>
  <p>No reviews found.</p>
</else>

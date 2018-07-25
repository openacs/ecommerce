<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<if @found_p;literal@ false>
<p>Gift certificate not found.</p>
</if><else>
  <table>
    @doc_body;noquote@
  </table>
</else>

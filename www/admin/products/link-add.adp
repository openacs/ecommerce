<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>



<if @no_rows@ false>
<p>Please select the product you wish to link to or from:</p>
<ul>
@doc_body;noquote@
</ul>
</if><else>
<p> 
No products found.
</p>

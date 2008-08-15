<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>Links <b>from</b> the page for @product_name;noquote@ to other products' display pages:</p>
<if @product_counter_a2@ gt 0>
<ul>
@doc_body_a2;noquote@
</ul>
</if>
<else><p>None.</p>
</else>

<p>Links <b>to</b> @product_name;noquote@ from other products' display pages:</p>
<if @product_counter_2a@ gt 0>
<ul>
@doc_body_2a;noquote@
</ul>
</if>
<else><p>None.</p>
</else>

<h3>Search for a product to add a link to/from:</h3>

<form method=post action=link-add>
@export_product_id_html;noquote@
        Name: <input type=text name=link_product_name size=20>
        <input type=submit value="Search">
</form>

<form method=post action=link-add>
@export_product_id_html;noquote@
       SKU: <input type=text name=link_product_sku size=10>
       <input type=submit value="Search">
</form>

<h3>Audit Trail</h3>
<ul>
  <li><a href="@audit_url_html;noquote@">Audit Links from @product_name;noquote@</a></li>
</ul>

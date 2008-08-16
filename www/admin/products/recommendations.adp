<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<h3>Currently Recommended Products</h3>
<p>
These products show up when the customer is browsing the site, either on the
home page (if a product is recommended at the top level), or when the
customer is browsing categories, subcategories, or subsubcategories.
</p><p>
You can also associate product recommendations with a user class if you
only want people in that user class to see a given recommendation.
</p>
<ul>
@moby_string;noquote@
</ul>

<h3>Add a Recommendation</h3>

<form method=post action=recommendation-add>
  <p>Search for a product to recommend:</p>
  <input type=text size=15 name=product_name_query>
  <input type=submit value="Search">
</form>

<h3>Options</h3>
<ul>
 <li><a href="@audit_url_html;noquote@">Audit all Recommendations</a>
</ul>

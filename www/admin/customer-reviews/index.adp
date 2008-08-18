<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<if @requires_approval@ true>
  <p>Comments must be approved before they will appear on the web site.</p>
</if><else>
<p>The ecommerce system is set up so that user's comments about products automatically appear
on the web site, unless you specifically Disapprove them.  Even though
it is not necessary, you may also wish to specifically Approve comments
so that you can distinguish them from comments that you have not yet
looked at.</p>
</else>

  <ul>
    @approved_reviews_html;noquote@
    <li><a href="@audit_url;noquote@">Audit All Customer Reviews</a></li>
  </ul>

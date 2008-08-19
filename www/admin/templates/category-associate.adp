<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>
The point of doing this is just to make it a little faster when
you are adding new products.  It is completely optional.
</p>

If you associate this template with a product category, then whenever
you add a new product of that category, the product will by default be
set to display with this template, although you can always change it.
(However, if you add a new product and put it in more than one
category, then this template might not end up being the default for
that product.)

<p>

This template may be associated with as many categories as you like.

<if @n_categories_associated_with@ gt 0>
<p>Currently this template is associated with the
category(ies):</p><ul>
@template_associations_html;noquote@
</ul>
</if><else>
<p>This template has not yet been associated with any categories.</p>
</else>

<if @n_categories_left@ eq 0>
  <p>All categories are associated with this template.  There are none left to add!</p>
</if><else>
  <form method=post action=category-associate-2>
    @export_form_vars_html;noquote@
    <p>Category: 
    <select name=category_id>
      @remaining_categories_html;noquote@
    </select>
    <input type=submit value="Associate">
    </p>
    </form>
</else>

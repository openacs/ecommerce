<?xml version="1.0"?>

<queryset>

  <fullquery name="froogle::upload.get_products">
    <querytext>
      select p.product_id, p.dirname, p.product_name as name, p.one_line_description || ' ' || p.detailed_description as description, c.category_name as category
      from ec_products p, ec_category_product_map m, ec_categories c
      where p.product_id = m.product_id
      and c.category_id = m.category_id
      and p.active_p = 't'
    </querytext>
  </fullquery>

</queryset>

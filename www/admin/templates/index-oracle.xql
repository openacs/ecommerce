<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="get_templates_info">      
      <querytext>
      
SELECT t.template_id, t.template_name, c.category_id, c.category_name
  FROM ec_templates t, ec_category_template_map m, ec_categories c
 WHERE t.template_id = m.template_id (+)
   and m.category_id = c.category_id (+)
  ORDER BY template_name, category_name
      </querytext>
</fullquery>

 
</queryset>

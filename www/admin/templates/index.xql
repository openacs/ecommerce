<?xml version="1.0"?>
<queryset>

<fullquery name="get_templates_info">      
      <querytext>

SELECT t.template_id, t.template_name, c.category_id, c.category_name
  FROM ec_templates t
	LEFT JOIN ec_category_template_map m using (template_id)
	LEFT JOIN ec_categories c on (m.category_id = c.category_id)
  ORDER BY template_name, category_name

      </querytext>
</fullquery>

 
</queryset>

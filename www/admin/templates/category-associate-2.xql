<?xml version="1.0"?>
<queryset>

<fullquery name="check_existence_t">      
      <querytext>
      select template_name as old_template from
ec_templates, ec_category_template_map m
where ec_templates.template_id = m.template_id
and m.category_id=:category_id
      </querytext>
</fullquery>

 
<fullquery name="insert_cat_temp_map">      
      <querytext>
      insert into ec_category_template_map (category_id, template_id) values (:category_id, :template_id)
      </querytext>
</fullquery>

 
<fullquery name="update_cat_temp_map">      
      <querytext>
      update ec_category_template_map set template_id=:template_id where category_id=:category_id
      </querytext>
</fullquery>

 
<fullquery name="get_template_name">      
      <querytext>
      select template_name from ec_templates where template_id=:template_id
      </querytext>
</fullquery>

 
<fullquery name="unused">      
      <querytext>
      select category_name from ec_categories where category_id=:category_id
      </querytext>
</fullquery>

 
</queryset>

<?xml version="1.0"?>
<queryset>

<fullquery name="get_template_data">      
      <querytext>
      
select template_name, template
  from ec_templates
  where template_id=:template_id

      </querytext>
</fullquery>

 
<fullquery name="get_n_category_assocs">      
      <querytext>
      
select count(*)
  from ec_category_template_map
 where template_id=:template_id

      </querytext>
</fullquery>

 
<fullquery name="get_each_template_assoc">      
      <querytext>
      
    select m.category_id, c.category_name
      from ec_category_template_map m, ec_categories c
     where m.category_id = c.category_id
       and m.template_id = :template_id
    
      </querytext>
</fullquery>

 
<fullquery name="get_n_left">      
      <querytext>
      
select count(*)
  from ec_categories
 where category_id not in (select category_id
                             from ec_category_template_map
                            where template_id=:template_id)

      </querytext>
</fullquery>

 
<fullquery name="get_remaining_categories">      
      <querytext>
      
    select category_id, category_name
      from ec_categories
     where category_id not in (select category_id
                                 from ec_category_template_map
                                where template_id=:template_id)
    
      </querytext>
</fullquery>

 
</queryset>

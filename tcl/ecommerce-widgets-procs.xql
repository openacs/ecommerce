<?xml version="1.0"?>

<queryset>

  <fullquery name="ec_only_category_widget.get_ec_categories">      
    <querytext>
      select category_id, category_name
      from ec_categories
      order by category_name
    </querytext>
  </fullquery>

  <fullquery name="ec_combocategory_widget.get_combocategories">      
    <querytext>
      select c.category_id, s.subcategory_id, category_name, subcategory_name 
      from ec_categories c left
      outer join ec_subcategories s using (category_id)
    </querytext>
  </fullquery>
  
  <fullquery name="ec_subcategory_widget.get_subcats_by_name">      
    <querytext>
      select subcategory_id, subcategory_name
      from ec_subcategories
      where category_id = :category_id
      order by subcategory_name
    </querytext>
  </fullquery>

  <fullquery name="ec_subcategory_with_subsubcategories_widget.get_subcategory_ids">      
    <querytext>
      select subcategory_id
      from ec_subcategories 
      where category_id = :category_id
    </querytext>
  </fullquery>

  <fullquery name="ec_subcategory_with_subsubcategories_widget.get_subcategory_names">      
    <querytext>
      select subcategory_name
      from ec_subcategories 
      where subcategory_id = :subcategory_id
    </querytext>
  </fullquery>
  
  <fullquery name="ec_determine_categorization_widget_defaults.get_sub_list">      
    <querytext>
      select subcategory_id
      from ec_subcategories 
      where category_id = :category_id
      and subcategory_id in ([join $subcategory_list ","]) 
      order by subcategory_name
    </querytext>
  </fullquery>

  
  <fullquery name="ec_determine_categorization_widget_defaults.get_subsub_list">      
    <querytext>
      select subsubcategory_id
      from ec_subsubcategories 
      where subcategory_id = :subcategory_id
      and subsubcategory_id in ([join $subsubcategory_list ","]) 
      order by subsubcategory_name
    </querytext>
  </fullquery>

  
  <fullquery name="ec_issue_type_widget.get_picklist_items">      
    <querytext>
      select picklist_item
      from ec_picklist_items
      where picklist_name = 'issue_type'
      order by sort_key
    </querytext>
  </fullquery>
  
  <fullquery name="ec_info_used_widget.get_info_used_list">      
    <querytext>
      select picklist_item
      from ec_picklist_items
      where picklist_name = 'info_used'
      order by sort_key
    </querytext>
  </fullquery>
  
  <fullquery name="ec_interaction_type_widget.get_interaction_type_list">      
    <querytext>
      select picklist_item
      from ec_picklist_items
      where picklist_name='interaction_type'
      order by sort_key
    </querytext>
  </fullquery>
  
</queryset>

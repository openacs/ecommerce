<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="ec_date_widget.date_widget_select">      
      <querytext>
      select to_char(current_timestamp, 'YYYY-MM-DD') 
      </querytext>
</fullquery>

 
<fullquery name="ec_time_widget.time_widget_select">      
      <querytext>
      select to_char(current_timestamp, 'HH24:MI:SS') 
      </querytext>
</fullquery>


<fullquery name="ec_category_widget.get_category_info_joined_w_children">
      <querytext>

    select c.category_id, c.category_name,
           s.subcategory_id, s.subcategory_name,
           ss.subsubcategory_id, ss.subsubcategory_name
      from ec_categories c
	   LEFT JOIN ec_subcategories s using (category_id)
	   LEFT JOIN ec_subsubcategories ss on (s.subcategory_id = ss.subcategory_id)
  order by c.sort_key, s.sort_key, ss.sort_key

      </querytext>
</fullquery>
 
</queryset>

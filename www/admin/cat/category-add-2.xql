<?xml version="1.0"?>
<queryset>

<fullquery name="get_category_confirmation">      
      <querytext>
      select category_id from ec_categories
where category_id=:category_id
      </querytext>
</fullquery>

 
<fullquery name="get_n_conflicts">      
      <querytext>
      select count(*)
from ec_categories
where sort_key = (:prev_sort_key + :next_sort_key)/2
      </querytext>
</fullquery>

 
</queryset>

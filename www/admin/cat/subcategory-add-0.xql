<?xml version="1.0"?>
<queryset>

<fullquery name="get_n_conflicts">      
      <querytext>
      select count(*)
from ec_subcategories
where category_id=:category_id
and sort_key = (:prev_sort_key + :next_sort_key)/2
      </querytext>
</fullquery>

 
</queryset>

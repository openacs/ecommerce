<?xml version="1.0"?>
<queryset>

<fullquery name="get_subcat_id">      
      <querytext>
      select subsubcategory_id from ec_subsubcategories
where subsubcategory_id=:subsubcategory_id
      </querytext>
</fullquery>

 
<fullquery name="get_n_conflicts">      
      <querytext>
      select count(*)
from ec_subsubcategories
where subcategory_id=:subcategory_id
and sort_key = (:prev_sort_key + :next_sort_key)/2
      </querytext>
</fullquery>

 
</queryset>

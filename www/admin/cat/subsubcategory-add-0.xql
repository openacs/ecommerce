<?xml version="1.0"?>
<queryset>

<fullquery name="get_n_conflicts">      
      <querytext>
      select count(*)
from ec_subsubcategories
where subcategory_id=:subcategory_id
and sort_key = :sort_key
      </querytext>
</fullquery>

 
</queryset>

<?xml version="1.0"?>
<queryset>

<fullquery name="sub_id_select">      
      <querytext>
      select subcategory_id from ec_subcategories
where subcategory_id=:subcategory_id
      </querytext>
</fullquery>

 
<fullquery name="get_n_conflicts">      
      <querytext>
      select count(*)
from ec_subcategories
where category_id=:category_id
and sort_key = :sort_key
      </querytext>
</fullquery>

 
</queryset>

<?xml version="1.0"?>
<queryset>

<fullquery name="get_n_conflicts">      
      <querytext>
      select count(*)
from ec_categories
where sort_key = :sort_key
      </querytext>
</fullquery>

 
</queryset>

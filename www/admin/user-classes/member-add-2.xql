<?xml version="1.0"?>
<queryset>

<fullquery name="get_ucm_count">      
      <querytext>
      select count(*) from ec_user_class_user_map where user_id=:user_id and user_class_id=:user_class_id
      </querytext>
</fullquery>

 
</queryset>

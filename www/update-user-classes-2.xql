<?xml version="1.0"?>
<queryset>

<fullquery name="get_old_class_ids">      
      <querytext>
      select user_class_id 
    from ec_user_class_user_map 
    where user_id = :user_id
      </querytext>
</fullquery>

 
</queryset>

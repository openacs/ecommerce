<?xml version="1.0"?>
<queryset>

<fullquery name="get_user_id_list">      
      <querytext>
      select user_id from ec_user_class_user_map where user_class_id = :user_class_id
      </querytext>
</fullquery>

 
<fullquery name="delete_unmap_users">      
      <querytext>
      delete from ec_user_class_user_map where user_class_id=:user_class_id

      </querytext>
</fullquery>

 
<fullquery name="delete_from_user_class">      
      <querytext>
      delete from ec_user_classes
where user_class_id=:user_class_id

      </querytext>
</fullquery>

 
</queryset>

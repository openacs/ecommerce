<?xml version="1.0"?>
<queryset>

<fullquery name="get_uc_info_lines">      
      <querytext>

   select ec_user_classes.user_class_id, 
          ec_user_classes.user_class_name,
          count(user_id) as n_users
     from ec_user_classes
	LEFT JOIN ec_user_class_user_map m using (user_class_id)
 group by ec_user_classes.user_class_id, ec_user_classes.user_class_name
 order by user_class_name

      </querytext>
</fullquery>

 
<fullquery name="get_n_approved_users">      
      <querytext>
      
        select count(*) as approved_n_users
          from ec_user_class_user_map
         where user_class_approved_p = 't'
          and user_class_id=:user_class_id
        
      </querytext>
</fullquery>

 
</queryset>

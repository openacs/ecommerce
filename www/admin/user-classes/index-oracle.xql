<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="get_uc_info_lines">      
      <querytext>
      
   select ec_user_classes.user_class_id, 
          ec_user_classes.user_class_name,
          count(user_id) as n_users
     from ec_user_classes, ec_user_class_user_map m
    where ec_user_classes.user_class_id = m.user_class_id(+)
 group by ec_user_classes.user_class_id, ec_user_classes.user_class_name
 order by user_class_name

      </querytext>
</fullquery>

 
</queryset>

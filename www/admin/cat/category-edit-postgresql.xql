<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="update_ec_categories">      
      <querytext>
      update ec_categories
set category_name=:category_name,
last_modified=current_timestamp,
last_modifying_user=:user_id,
modified_ip_address=:address
where category_id=:category_id
      </querytext>
</fullquery>

 
</queryset>

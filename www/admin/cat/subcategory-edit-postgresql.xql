<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="update_ec_subcats">      
      <querytext>
      update ec_subcategories
set subcategory_name=:subcategory_name,
last_modified=current_timestamp,
last_modifying_user=:user_id,
modified_ip_address=:address
where subcategory_id=:subcategory_id
      </querytext>
</fullquery>

 
</queryset>

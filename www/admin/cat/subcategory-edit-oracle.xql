<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="update_ec_subcats">      
      <querytext>
      update ec_subcategories
set subcategory_name=:subcategory_name,
last_modified=sysdate,
last_modifying_user=:user_id,
modified_ip_address=:address
where subcategory_id=:subcategory_id
      </querytext>
</fullquery>

 
</queryset>

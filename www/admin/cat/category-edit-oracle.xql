<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="update_ec_categories">      
      <querytext>
      update ec_categories
set category_name=:category_name,
last_modified=sysdate,
last_modifying_user=:user_id,
modified_ip_address=:address
where category_id=:category_id
      </querytext>
</fullquery>

 
</queryset>

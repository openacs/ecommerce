<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="insert_ec_subsubcat">      
      <querytext>
      insert into ec_subsubcategories
(subcategory_id, subsubcategory_id, subsubcategory_name, sort_key, last_modified, last_modifying_user, modified_ip_address)
values
(:subcategory_id, :subsubcategory_id, :subsubcategory_name, :sort_key, sysdate, :user_id,:address)
      </querytext>
</fullquery>

 
</queryset>

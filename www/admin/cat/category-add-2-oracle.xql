<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="insert_into_ec_categories">      
      <querytext>
      insert into ec_categories
(category_id, category_name, sort_key, last_modified, last_modifying_user, modified_ip_address)
values
(:category_id, :category_name, :sort_key, sysdate, :user_id, :peeraddr)
      </querytext>
</fullquery>

 
</queryset>

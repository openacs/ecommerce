<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="insert_into_ec_categories">      
      <querytext>
      insert into ec_categories
(category_id, category_name, sort_key, last_modified, last_modifying_user, modified_ip_address)
values
(:category_id, :category_name, :sort_key, current_timestamp, :user_id, :peeraddr)
      </querytext>
</fullquery>

 
</queryset>

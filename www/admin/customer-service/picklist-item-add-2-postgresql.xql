<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="insert_new_picklist_item">      
      <querytext>
      insert into ec_picklist_items
(picklist_item_id, picklist_item, picklist_name, sort_key, last_modified, last_modifying_user, modified_ip_address)
values
(:picklist_item_id, :picklist_item, :picklist_name, ($prev_sort_key + $next_sort_key)/2, current_timestamp, :user_id,:address)
      </querytext>
</fullquery>

 
</queryset>

<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="custom_product_field_insert">      
      <querytext>
      insert into ec_custom_product_field_values (product_id, last_modified, last_modifying_user, modified_ip_address) values (:val_$product_id_column, current_timestamp, :user_id, :peeraddr)
      </querytext>
</fullquery>

 
</queryset>

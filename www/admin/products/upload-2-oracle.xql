<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="custom_product_field_insert">      
      <querytext>
      insert into ec_custom_product_field_values (product_id, last_modified, last_modifying_user, modified_ip_address) values (:val_$product_id_column, sysdate, :user_id, :peeraddr)
      </querytext>
</fullquery>

 
</queryset>

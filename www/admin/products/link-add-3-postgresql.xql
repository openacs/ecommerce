<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="to_link_insert">      
      <querytext>
      insert into ec_product_links
      (product_a, product_b, last_modified, last_modifying_user, modified_ip_address)
      values
      (:link_product_id, :product_id, current_timestamp, :user_id, :peeraddr)
      
      </querytext>
</fullquery>

 
<fullquery name="from_link_insert">      
      <querytext>
      insert into ec_product_links
      (product_a, product_b, last_modified, last_modifying_user, modified_ip_address)
      values
      (:product_id, :link_product_id, current_timestamp, :user_id, :peeraddr)
      
      </querytext>
</fullquery>

 
</queryset>

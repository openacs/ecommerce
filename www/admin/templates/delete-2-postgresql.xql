<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="delete_product_refs">      
      <querytext>
      update ec_products set template_id=null, last_modified=current_timestamp, last_modifying_user=:user_id, modified_ip_address='[DoubleApos [ns_conn peeraddr]]' where template_id=:template_id
      </querytext>
</fullquery>

 
</queryset>

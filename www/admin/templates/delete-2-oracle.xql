<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="delete_product_refs">      
      <querytext>
      update ec_products set template_id=null, last_modified=sysdate, last_modifying_user=:user_id, modified_ip_address='[DoubleApos [ns_conn peeraddr]]' where template_id=:template_id
      </querytext>
</fullquery>

 
</queryset>

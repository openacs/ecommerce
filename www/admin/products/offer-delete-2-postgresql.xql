<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="offer_delete_update">      
      <querytext>
      
update ec_offers
set deleted_p=:deleted_p,
    last_modified=current_timestamp,
    last_modifying_user=:user_id,
    modified_ip_address=:peeraddr
where product_id=:product_id
and retailer_id=:retailer_id

      </querytext>
</fullquery>

 
</queryset>

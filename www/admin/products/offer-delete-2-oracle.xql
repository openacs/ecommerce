<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="offer_delete_update">      
      <querytext>
      
update ec_offers
set deleted_p=:deleted_p,
    last_modified=sysdate,
    last_modifying_user=:user_id,
    modified_ip_address=:peeraddr
where product_id=:product_id
and retailer_id=:retailer_id

      </querytext>
</fullquery>

 
</queryset>

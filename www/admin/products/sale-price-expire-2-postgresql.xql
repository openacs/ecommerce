<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="expire_sale_update">      
      <querytext>
      
update ec_sale_prices
set sale_ends=current_timestamp,
    last_modified=current_timestamp,
    last_modifying_user=:user_id,
    modified_ip_address=:peeraddr
where sale_price_id=:sale_price_id

      </querytext>
</fullquery>

 
</queryset>

<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="expire_sale_update">      
      <querytext>
      
update ec_sale_prices
set sale_ends=sysdate,
    last_modified=sysdate,
    last_modifying_user=:user_id,
    modified_ip_address=:peeraddr
where sale_price_id=:sale_price_id

      </querytext>
</fullquery>

 
</queryset>

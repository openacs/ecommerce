<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="sale_price_update">      
      <querytext>
      
update ec_sale_prices
set sale_price=:sale_price,
    sale_begins=to_date(:sale_begins,'YYYY-MM-DD HH24:MI:SS'),
    sale_ends=to_date(:sale_ends,'YYYY-MM-DD HH24:MI:SS'),
    sale_name=:sale_name,
    offer_code=:offer_code,
    last_modified=current_timestamp,
    last_modifying_user=:user_id,
    modified_ip_address=:peeraddr
where sale_price_id=:sale_price_id

      </querytext>
</fullquery>

 
</queryset>

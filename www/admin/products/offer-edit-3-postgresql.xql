<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="unused">      
      <querytext>
      
update ec_offers
set retailer_id = :retailer_id,
    price = :price,
    shipping = :shipping,
    stock_status = :stock_status,
    special_offer_p = :special_offer_p,
    special_offer_html = :special_offer_html,
    offer_begins = to_date(:offer_begins, 'YYYY-MM-DD HH24:MI:SS'),
    offer_ends = to_date(:offer_ends, 'YYYY-MM-DD HH24:MI:SS') $additional_thing_to_insert,
    last_modified = current_timestamp,
    last_modifying_user = :user_id,
    modified_ip_address = :peeraddr
where offer_id = :offer_id

      </querytext>
</fullquery>

 
</queryset>

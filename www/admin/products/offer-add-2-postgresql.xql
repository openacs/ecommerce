<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="offer_insert">      
      <querytext>
      
insert into ec_offers
(offer_id, product_id, retailer_id, price, shipping, stock_status,
 special_offer_p, special_offer_html, offer_begins,
 offer_ends $additional_column, last_modified, last_modifying_user,
 modified_ip_address)
values
(:offer_id, :product_id, :retailer_id, :price, :shipping, :stock_status,
 :special_offer_p, :special_offer_html,
 to_date(:offer_begins, 'YYYY-MM-DD HH24:MI:SS'),
 to_date(:offer_ends,'YYYY-MM-DD HH24:MI:SS') $additional_value, current_timestamp,
 :user_id, :peeraddr)

      </querytext>
</fullquery>

 
</queryset>

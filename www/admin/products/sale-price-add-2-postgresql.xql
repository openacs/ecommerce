<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="sale_insert">      
      <querytext>
      insert into ec_sale_prices
(sale_price_id, product_id, sale_price, sale_begins, sale_ends, sale_name, offer_code, last_modified, last_modifying_user, modified_ip_address)
values
(:sale_price_id, :product_id, :sale_price, to_date(:sale_begins,'YYYY-MM-DD HH24:MI:SS'), to_date(:sale_ends,'YYYY-MM-DD HH24:MI:SS'), :sale_name, :offer_code, current_timestamp, :user_id, :peeraddr)
      </querytext>
</fullquery>

 
</queryset>

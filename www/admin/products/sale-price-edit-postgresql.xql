<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="sale_price_select">      
      <querytext>
      select sale_price, to_char(sale_begins,'YYYY-MM-DD HH24:MI:SS') as sale_begins, to_char(sale_ends,'YYYY-MM-DD HH24:MI:SS') as sale_ends, sale_name, offer_code from ec_sale_prices where sale_price_id=:sale_price_id
      </querytext>
</fullquery>

 
</queryset>

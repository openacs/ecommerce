<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="get_saved_date">      
      <querytext>
      select to_char(in_basket_date,'Month DD, YYYY') as formatted_in_basket_date from ec_orders where order_id=:order_id
      </querytext>
</fullquery>

 
</queryset>

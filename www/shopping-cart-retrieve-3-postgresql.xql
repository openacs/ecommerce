<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="get_saved_date">      
      <querytext>
      select to_char(in_basket_date,'Month DD, YYYY') as formatted_in_basket_date from ec_orders where order_id=:order_id
      </querytext>
</fullquery>

 
</queryset>

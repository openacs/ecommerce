<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="get_order_cost">      
      <querytext>
      
     select ec_order_cost(:order_id) as otppgc,
            ec_gift_certificate_balance(:user_id) as user_gift_certificate_balance
       
     
      </querytext>
</fullquery>

 
</queryset>

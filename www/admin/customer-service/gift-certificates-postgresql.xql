<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="get_pretty_price">      
      <querytext>
      select ec_gift_certificate_balance(:user_id) 
      </querytext>
</fullquery>

 
</queryset>

<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="get_gc_balance">      
      <querytext>
      select ec_gift_certificate_balance(:user_id) 
      </querytext>
</fullquery>

 
<fullquery name="get_id_for_new_cc">      
      <querytext>
      select ec_creditcard_id_sequence.nextval 
      </querytext>
</fullquery>

 
</queryset>

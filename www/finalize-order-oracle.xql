<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="get_gc_balance">      
      <querytext>
      select ec_gift_certificate_balance(:user_id) from dual
      </querytext>
</fullquery>

 
</queryset>

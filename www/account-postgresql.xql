<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="get_gift_certificate_balance">      
      <querytext>
      select ec_gift_certificate_balance(:user_id) 
      </querytext>
</fullquery>

 
<fullquery name="get_user_view_classes">      
      <querytext>
      select 1  where exists (select 1 from ec_user_classes)
      </querytext>
</fullquery>

 
</queryset>

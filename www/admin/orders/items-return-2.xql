<?xml version="1.0"?>
<queryset>

  <fullquery name="get_refund_count">      
    <querytext>
      select count(*) 
      from ec_refunds
      where refund_id=:refund_id
    </querytext>
  </fullquery>
  
</queryset>

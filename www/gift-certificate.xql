<?xml version="1.0"?>
<queryset>

<fullquery name="get_gc_info">      
      <querytext>
      select purchased_by, amount, recipient_email, certificate_to, certificate_from, certificate_message from ec_gift_certificates where gift_certificate_id=:gift_certificate_id
      </querytext>
</fullquery>

 
</queryset>

<?xml version="1.0"?>
<queryset>

<fullquery name="num_items_select">      
      <querytext>
      select count(*) from ec_items where order_id=:order_id and product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="amount_charged_minus_refunded_for_nonvoid_items_select">      
      <querytext>
      select coalesce(sum(coalesce(price_charged,0)) + sum(coalesce(shipping_charged,0)) + sum(coalesce(price_tax_charged,0)) + sum(coalesce(shipping_tax_charged,0)) - sum(coalesce(price_refunded,0)) - sum(coalesce(shipping_refunded,0)) + sum(coalesce(price_tax_refunded,0)) - sum(coalesce(shipping_tax_refunded,0)),0) from ec_items where item_state <> 'void' and order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="certs_to_reinstate_list_select">      
      <querytext>
      select u.gift_certificate_id
    from ec_gift_certificate_usage u, ec_gift_certificates c
    where u.gift_certificate_id = c.gift_certificate_id
    and u.order_id = :order_id
    order by expires desc
      </querytext>
</fullquery>

 
</queryset>

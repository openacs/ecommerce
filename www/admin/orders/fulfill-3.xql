<?xml version="1.0"?>
<queryset>

  <fullquery name="doubleclick_select">      
    <querytext>
      select count(*) 
      from ec_shipments
      where shipment_id=:shipment_id
    </querytext>
  </fullquery>

  <fullquery name="shipping_method_select">      
    <querytext>
      select shipping_method
      from ec_orders
      where order_id=:order_id
    </querytext>
  </fullquery>

  <fullquery name="shippable_p_select">      
    <querytext>
      select shipping_method 
      from ec_orders
      where order_id=:order_id
    </querytext>
  </fullquery>
  
  <fullquery name="total_price_of_items_select">      
    <querytext>
      select coalesce(sum(price_charged),0) 
      from ec_items
      where item_id in ([join $item_id_list ", "])
    </querytext>
  </fullquery>
  
  <fullquery name="n_shipments_already_select">      
    <querytext>
      select count(*) 
      from ec_shipments
      where order_id=:order_id
    </querytext>
  </fullquery>
  
  <fullquery name="shipping_of_items_select">      
    <querytext>
      select coalesce(sum(shipping_charged),0) 
      from ec_items
      where item_id in ([join $item_id_list ", "])
    </querytext>
  </fullquery>
    
  <fullquery name="item_state_update">      
    <querytext>
      update ec_items
      set item_state='shipped', shipment_id=:shipment_id
      where item_id in ([join $item_id_list ", "])
    </querytext>
  </fullquery>

  <fullquery name="authorized_amount_select">      
    <querytext>
      select transaction_amount
      from ec_financial_transactions
      where order_id = :order_id
      and to_be_captured_p is null
      and authorized_date is not null
      and transaction_type = 'charge'
    </querytext>
  </fullquery>
  
  <fullquery name="transaction_id_select">      
    <querytext>
      select transaction_id
      from ec_financial_transactions 
      where order_id=:order_id
      and to_be_captured_p is null
      and transaction_type = 'charge'
    </querytext>
  </fullquery>
  
  <fullquery name="transaction_failed_update">      
    <querytext>
      update ec_financial_transactions 
      set failed_p='t'
      where transaction_id=:transaction_id
    </querytext>
  </fullquery>
  
</queryset>

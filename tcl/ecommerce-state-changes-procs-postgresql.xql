<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>postgresql</type>
    <version>7.1</version>
  </rdbms>

  <fullquery name="ec_update_state_to_in_basket.reinst_gift_cert_on_order">      
    <querytext>
      select ec_reinst_gift_cert_on_order (:order_id)
    </querytext>
  </fullquery>

  <fullquery name="ec_update_state_to_authorized.set_order_authorized">      
    <querytext>
      update ec_orders 
      set order_state = 'authorized', authorized_date = current_timestamp 
      where order_id = :order_id
    </querytext>
  </fullquery>

  <fullquery name="ec_update_state_to_authorized.record_soft_goods_shipment">
    <querytext>
      insert into ec_shipments
      (shipment_id, order_id, shipment_date, expected_arrival_date, carrier, shippable_p, last_modified, last_modifying_user, modified_ip_address)
      select :shipment_id, :order_id, current_timestamp, current_timestamp, 'none', 'f', current_timestamp, user_id, :peeraddr from ec_orders where order_id = :order_id
    </querytext>
  </fullquery>

  <fullquery name="ec_update_state_to_confirmed.order_state_update">
    <querytext>
      update ec_orders 
      set order_state='confirmed', confirmed_date=current_timestamp
      where order_id=:order_id
    </querytext>
  </fullquery>

  <fullquery name="ec_update_state_to_confirmed.total_amount_select">      
    <querytext>
      select ec_order_cost(:order_id) 
    </querytext>
  </fullquery>

  <fullquery name="ec_update_state_to_confirmed.financial_transaction_insert">      
    <querytext>
      insert into ec_financial_transactions
      (transaction_id, order_id, transaction_amount, transaction_type, inserted_date)
      values
      (:transaction_id, :order_id, :total_amount, 'charge', current_timestamp)
    </querytext>
  </fullquery>

  <fullquery name="ec_apply_gift_certificate_balance.amount_owed_select">      
    <querytext>
      select ec_order_amount_owed(:order_id) 
    </querytext>
  </fullquery>

  <fullquery name="ec_apply_gift_certificate_balance.available_gift_certificates">      
    <querytext>
      select gift_certificate_id, gift_certificate_amount_left(gift_certificate_id) as amount_available
      from ec_gift_certificates_approved
      where user_id = :user_id
      and current_timestamp - expires < 0
      and amount_remaining_p = 't'
      and gift_certificate_amount_left(gift_certificate_id) > 0
      order by expires
    </querytext>
  </fullquery>

  <fullquery name="ec_apply_gift_certificate_balance.gift_certificate_usage_insert">      
    <querytext>
      insert into ec_gift_certificate_usage
      (gift_certificate_id, order_id, amount_used, used_date)
      values
      (:gift_certificate_id, :order_id, 
      least(:amount_available, :amount_owed), current_timestamp)
    </querytext>
  </fullquery>

  <fullquery name="ec_apply_gift_certificate_balance.gift_certificate_balance_select">      
    <querytext>
      select ec_gift_certificate_balance(:user_id) 
    </querytext>
  </fullquery>

  <fullquery name="ec_apply_gift_certificate_balance.amount_owed_select">      
    <querytext>
      select ec_order_amount_owed(:order_id) 
    </querytext>
  </fullquery>

  <fullquery name="ec_update_state_to_authorized.order_contains_soft_goods">      
    <querytext>
	select item_id
	from ec_items i, ec_products p 
	where i.order_id = :order_id
	and i.product_id = p.product_id
	and p.no_shipping_avail_p = 't'
	limit 1
    </querytext>
  </fullquery>

  <fullquery name="ec_update_state_to_authorized.set_hard_goods_to_be_shipped">      
    <querytext>
      update ec_items 
      set item_state = 'to_be_shipped' 
      from ec_products p
      where ec_items.order_id = :order_id
      and ec_items.product_id = p.product_id
      and p.no_shipping_avail_p = 'f'
    </querytext>
  </fullquery>

  <fullquery name="ec_update_state_to_authorized.set_soft_goods_shipped">
    <querytext>
      update ec_items
      set item_state = 'shipped', shipment_id = :shipment_id
      from ec_products p
      where ec_items.order_id = :order_id
      and ec_items.product_id = p.product_id
      and p.no_shipping_avail_p = 't'
    </querytext>
  </fullquery>

</queryset>

<?xml version="1.0"?>
<queryset>

<fullquery name="get_user_id">      
      <querytext>
      select user_id from ec_orders where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="get_refund_id_check">      
      <querytext>
      select count(*) from ec_refunds where refund_id=:refund_id
      </querytext>
</fullquery>

 
<fullquery name="get_credit_card_id">      
      <querytext>
      select creditcard_number from ec_orders o, ec_creditcards c where o.creditcard_id=c.creditcard_id and o.order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="get_creditcard_id">      
      <querytext>
      select creditcard_id from ec_orders where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="get_transaction_to_query">      
      <querytext>
      
	select max(transaction_id)
	from ec_financial_transactions
	where creditcard_id=:creditcard_id
	 and (authorized_date is not null OR 0=(select count(*) from ec_financial_transactions where creditcard_id=:creditcard_id and authorized_date is not null)
	
      </querytext>
</fullquery>

 
<fullquery name="get_creditcard_id">      
      <querytext>
      select creditcard_id from ec_orders where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="update_cc_number_incctable">      
      <querytext>
      update ec_creditcards set creditcard_number=:creditcard_number where creditcard_id=:creditcard_id
      </querytext>
</fullquery>

 
<fullquery name="insert_new_cc">      
      <querytext>
      insert into ec_creditcards
	(creditcard_id, user_id, creditcard_number, creditcard_last_four, creditcard_type, creditcard_expire, billing_zip_code)
	values
	(:creditcard_id, :user_id, :creditcard_number, :cc_thing, :creditcard_type,:expires,:billing_zip_code)
	
      </querytext>
</fullquery>

 
<fullquery name="get_tax_charged_on_item">      
      <querytext>
      select coalesce(price_tax_charged,0) as price_tax_charged, coalesce(shipping_tax_charged,0) as shipping_tax_charged from ec_items where item_id=:item_id
      </querytext>
</fullquery>

 
<fullquery name="update_item_return">      
      <querytext>
      
	update ec_items set item_state='received_back',
	                    received_back_date=to_date(:received_back_datetime,'YYYY-MM-DD HH12:MI:SSAM'),
                            price_refunded=:price_bind_variable,
                            shipping_refunded=:shipping_bind_variable,
                            price_tax_refunded=:price_tax_to_refund,
                            shipping_tax_refunded=:shipping_tax_to_refund,
                            refund_id=:refund_id
               where item_id=:item_id
      </querytext>
</fullquery>

 
<fullquery name="get_base_shipping_tax">      
      <querytext>
      select coalesce(shipping_tax_charged,0) from ec_orders where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="update_ec_order_set_shipping_refunds">      
      <querytext>
      update ec_orders set shipping_refunded=:base_shipping_to_refund, shipping_tax_refunded=:base_shipping_tax_to_refund where order_id=:order_id
      </querytext>
</fullquery>

 
</queryset>

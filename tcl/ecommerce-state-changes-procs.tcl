ad_library {

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @author ported by Jerry Asher (jerry@theashergroup.com)
  @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
  @revision-date March 2002

}

ad_proc ec_update_state_to_in_basket { 
    order_id 
} { 

    If a credit card failure occurs, the following actions
    need to be taken:

    1. ec_orders.order_state becomes in_basket
    2. ec_creditcards.failed_p becomes t
    3. any gift certificates used should be reinstated
    4. confirmed_date is set to null (because we use existence of
       confirmed_date to see if order is confirmed yet)
    5. ec_financial_transactions.transaction_type becomes null

    Call this procedure from within a transaction

} {
    db_1row credit_user_select "
        select creditcard_id, user_id 
        from ec_orders 
        where order_id=:order_id"
    db_dml order_state_update "
        update ec_orders 
        set order_state='in_basket', confirmed_date=null 
        where order_id=:order_id"
    db_dml creditcard_update "
        update ec_creditcards 
        set failed_p='t' 
        where creditcard_id=:creditcard_id"
    db_exec_plsql reinst_gift_cert_on_order "
	declare 
	begin 
	    ec_reinst_gift_cert_on_order (:order_id); 
	end;"
# following cleans up errors resulting from ccard failures with shipping fulfill-3.tcl
    db_dml update_transaction_state "
        update ec_financial_transactions
        set to_be_captured_p = 'f'
        where order_id=:order_id
        and creditcard_id=:creditcard_id"
}

ad_proc ec_update_state_to_authorized {
    order_id
} {
    If a credit card authorization occurs, the following actions
    need to be taken:

    1. ec_orders.order_state becomes authorized
    2. ec_orders.authorized_date is filled in
    3. all items in ec_items in that order need to have their state
       updated to to_be_shipped

} {

    db_dml set_order_authorized "
	update ec_orders 
	set order_state = 'authorized', authorized_date = sysdate 
	where order_id = :order_id"

    # Soft goods don't require shipping and can go directly to the
    # 'shipped' state.
    
    if {[db_0or1row order_contains_soft_goods "
	select item_id
	from ec_items i, ec_products p 
	where i.order_id = :order_id
	and i.product_id = p.product_id
	and p.no_shipping_avail_p = 't'
	limit 1"]} {
	set peeraddr [ns_conn peeraddr]
	set shipment_id [db_nextval ec_shipment_id_sequence]
	db_dml record_soft_goods_shipment "
	    insert into ec_shipments
	    (shipment_id, order_id, shipment_date, expected_arrival_date, carrier, shippable_p, last_modified, last_modifying_user, modified_ip_address)
	    select :shipment_id, order_id, sysdate, sysdate, 'none', 'f', sysdate, user_id, :peeraddr from ec_orders where order_id = :order_id"

	db_dml set_soft_goods_shipped "
	    update ec_items
	    set item_state = 'shipped', shipment_id = :shipment_id
	    from ec_products p
	    where ec_items.order_id = :order_id
	    and ec_items.product_id = p.product_id
	    and p.no_shipping_avail_p = 't'"
    }
    # Update the state of all hard goods from 'in_basket' to
    # 'to_be_shipped'.

    db_dml set_hard_goods_to_be_shipped "
	update ec_items 
	set item_state = 'to_be_shipped' 
	from ec_products p
	where ec_items.order_id = :order_id
	and ec_items.product_id = p.product_id
	and p.no_shipping_avail_p = 'f'"

}

ad_proc ec_update_state_to_confirmed {
 order_id
} {

    If an order is confirmed, the following actions need to be taken:

    1. ec_orders.order_state becomes confirmed
    2. ec_orders.confirmed_date is filled in
    3. gift_certificate needs to be applied
    4. If the total order cost is greater than 0, a row needs to be
       added to ec_financial_transactions

    Note: call this from within a transaction

} {

    set user_id [db_string user_id_select "
	select user_id 
	from ec_orders 
	where order_id=:order_id"]

    ec_apply_gift_certificate_balance $order_id $user_id

    db_dml order_state_update "
	update ec_orders 
	set order_state = 'confirmed', confirmed_date = sysdate 
	where order_id = :order_id"
}

ad_proc ec_apply_gift_certificate_balance { 
    order_id 
    user_id 
} { 

    This proc takes the place of the pl/sql procedure
    ec_apply_gift_cert_balance

} {
    set amount_owed [db_string amount_owed_select "
	select ec_order_amount_owed(:order_id) 
	from dual"]

    db_foreach available_gift_certificates "
  	select gift_certificate_id, gift_certificate_amount_left(gift_certificate_id) as amount_available
  	from ec_gift_certificates_approved
  	where user_id = :user_id
  	and sysdate - expires < 0
  	and amount_remaining_p = 't'
	and gift_certificate_amount_left(gift_certificate_id) > 0
  	order by expires" {

	if {$amount_owed > 0} {
	    db_dml gift_certificate_usage_insert "
		insert into ec_gift_certificate_usage
		(gift_certificate_id, order_id, amount_used, used_date)
		values
		(:gift_certificate_id, :order_id, least(to_number(:amount_available), to_number(:amount_owed)), sysdate)"
	    set amount_owed [db_string amount_owed_select "
		select ec_order_amount_owed(:order_id) 
		from dual"]
	}
    }
}

# /tcl/ecommerce-state-changes.tcl
ad_library {

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id ecommerce-state-changes.tcl,v 3.1.2.4 2000/08/17 17:37:16 seb Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
}

# If a credit card failure occurs, the following actions
# need to be taken:
# 1. ec_orders.order_state becomes in_basket
# 2. ec_creditcards.failed_p becomes t
# 3. any gift certificates used should be reinstated
# 4. confirmed_date is set to null (because we use existence of
#    confirmed_date to see if order is confirmed yet)
# Call this procedure from within a transaction
proc ec_update_state_to_in_basket { order_id } {
  db_1row credit_user_select "select creditcard_id, user_id from ec_orders where order_id=:order_id"
  db_dml order_state_update "update ec_orders set order_state='in_basket', confirmed_date=null where order_id=:order_id"
  db_dml creditcard_update "update ec_creditcards set failed_p='t' where creditcard_id=:creditcard_id"
  db_dml reinst_gift_cert_on_order "declare begin ec_reinst_gift_cert_on_order (:order_id); end;"
}

# If a credit card authorization occurs, the following actions
# need to be taken:
# 1. ec_orders.order_state becomes authorized_plus/minus_avs
# 2. ec_orders.authorized_date is filled in
# 3. all items in ec_items in that order need to have their state
#    updated to to_be_shipped
proc ec_update_state_to_authorized {order_id plus_avs_p} {
  if {$plus_avs_p == "t"} {
    set new_state "authorized_plus_avs"
  } else {
    set new_state "authorized_minus_avs"
  }
  # if the total order cost is more than 0, there should be a row in ec_financial_transactions
  # for this order
  if { [db_string order_cost_select "select ec_order_cost(:order_id) from dual"] > 0 } {
    set transaction_id [db_string transaction_select "select max(transaction_id) from ec_financial_transactions where order_id=:order_id"]
    db_dml authorized_date_update "update ec_financial_transactions set authorized_date=sysdate where transaction_id=:transaction_id"
  }

  db_dml order_state_update "update ec_orders set order_state=:new_state, authorized_date=sysdate where order_id=:order_id"
  db_dml set_to_be_shipped "update ec_items set item_state='to_be_shipped' where order_id=:order_id"
}

# If an order is confirmed, the following actions need to be taken:
# 1. ec_orders.order_state becomes confirmed
# 2. ec_orders.confirmed_date is filled in
# 3. gift_certificate needs to be applied
# 4. if the total order cost is greater than 0, a row needs to be added to ec_financial_transactions
# Note: call this from within a transaction
proc ec_update_state_to_confirmed {order_id} {
  set user_id [db_string user_id_select "select user_id from ec_orders where order_id=:order_id"]

  ns_log Notice "before ec_apply_gift_cert_balance($order_id,$user_id)"
  #    db_dml unused "declare begin ec_apply_gift_cert_balance($order_id, $user_id); end;"
  ec_apply_gift_certificate_balance $order_id $user_id
  ns_log Notice "end ec_apply_gift_cert_balance"

  db_dml order_state_update "update ec_orders set order_state='confirmed', confirmed_date=sysdate where order_id=:order_id"

  set total_amount [db_string total_amount_select "select ec_order_cost(:order_id) from dual"]
  if { $total_amount > 0 } {
    # create a new financial transaction
    set transaction_id [db_string transaction_id_select "select ec_transaction_id_sequence.nextval from dual"]
    db_dml financial_transaction_insert "insert into ec_financial_transactions
    (transaction_id, order_id, transaction_amount, transaction_type, inserted_date)
    values
    (:transaction_id, :order_id, :total_amount, 'charge', sysdate)"
  }
}

# this takes the place of the pl/sql procedure ec_apply_gift_cert_balance
proc ec_apply_gift_certificate_balance { order_id user_id } {
  set certificates_to_use [db_list certificates_to_use_select "
  select gift_certificate_id
  from ec_gift_certificates_approved
  where user_id=:user_id
  and sysdate - expires < 0
  and amount_remaining_p = 't'
  order by expires
  "]

  set gift_certificate_balance [db_string gift_certificate_balance_select "select ec_gift_certificate_balance(:user_id) from dual"]
  set amount_owed [db_string amount_owed_select "select ec_order_amount_owed(:order_id) from dual"]

  set counter 0
  while { $amount_owed > 0 && $gift_certificate_balance > 0 && [llength $certificates_to_use] > $counter} {
    ns_log Notice "ec_apply_gift_certificate_balance iteration $counter: gift_certificate_balance=$gift_certificate_balance, amount_owed=$amount_owed"
    set gift_certificate_id [lindex $certificates_to_use $counter]
    set gift_certificate_amount_left [db_string gift_certificate_amount_left_select "select gift_certificate_amount_left(:gift_certificate_id) from dual"]
	
    if { $gift_certificate_amount_left > 0 } {
#        http://www.arsdigita.com/bboard/q-and-a-fetch-msg?msg_id=000YLy&topic_id=21&topic=web%2fdb
#        db_dml gift_certificate_usage_insert "insert into ec_gift_certificate_usage
#        (gift_certificate_id, order_id, amount_used, used_date)
#        VALUES
#        (:gift_certificate_id, :order_id, least(:gift_certificate_amount_left, :amount_owed), sysdate)
#        "

      db_dml gift_certificate_usage_insert "insert into ec_gift_certificate_usage
      (gift_certificate_id, order_id, amount_used, used_date)
      VALUES
	(:gift_certificate_id, :order_id, least(to_number(:gift_certificate_amount_left),
        to_number(:amount_owed)), sysdate)
        "
    
      set gift_certificate_balance [db_string gift_certificate_balance_select "select ec_gift_certificate_balance(:user_id) from dual"]
      set amount_owed [db_string amount_owed_select "select ec_order_amount_owed(:order_id) from dual"]
    }

    incr counter
  }
  if { [llength $certificates_to_use] <= $counter } {
    ns_log Notice "ec_apply_gift_certificate_balance ran out of gift certificates to use before the gift certificate balance was supposedly used up!"
  }
}

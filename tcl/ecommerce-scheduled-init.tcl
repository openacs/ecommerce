# Schedule the recurring ecommerce procedures if there is a binding with a payment
# service contract.

# @creation-date 02 October 2000
# @author Bart Teeuwisse
# @cvs-id $Id$

if { [acs_sc_binding_exists_p "PaymentGateway" [ad_parameter PaymentGateway -default [ad_parameter -package_id [ec_id] PaymentGateway]]] } {

    # Scheduled proc scheduling:
    # Nightly pi time + 1 = 4:14am
    
    ns_schedule_daily -thread 4 14 ec_calculate_product_purchase_combinations

    # A few times a day every three hours or so (slightly different
    # intervals so they'll eventually space themselves out)

    set infrequent_base [expr 3 * 60 * 60]

    ad_schedule_proc -thread t [expr $infrequent_base + 0] ec_expire_old_carts
    
    ad_schedule_proc -thread t [expr $infrequent_base + 50] ec_unauthorized_transactions

    ad_schedule_proc -thread t [expr $infrequent_base + 10] ec_unmarked_transactions

    ad_schedule_proc -thread t [expr $infrequent_base + 200] ec_unrefunded_transactions

    # Often, every 10 - 15 minutes

    set frequent_base [expr 60 * 10]

    ad_schedule_proc -thread t [expr $frequent_base + 0] ec_sweep_for_payment_zombies

    ad_schedule_proc -thread t [expr $frequent_base + 25] ec_sweep_for_payment_zombie_gift_certificates

    ad_schedule_proc -thread t [expr $frequent_base + 50] ec_send_unsent_new_order_email

    ad_schedule_proc -thread t [expr $frequent_base + 100] ec_delayed_credit_denied

    ad_schedule_proc -thread t [expr $frequent_base + 150] ec_remove_creditcard_data

    ad_schedule_proc -thread t [expr $frequent_base + 200] ec_send_unsent_new_gift_certificate_order_email

    ad_schedule_proc -thread t [expr $frequent_base + 250] ec_send_unsent_gift_certificate_recipient_email
}

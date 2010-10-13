# set any form defaults here

# get form variables passed with connection
set __form [ns_getform]
if { $__form eq "" } {
    set __form_size 0
} else {
    set __form_size [ns_set size $__form]
}
for { set __form_counter_i 0 } { $__form_counter_i < $__form_size } { incr __form_counter_i } {
    
    # The name of the argument passed in the form
    set __form_key [ns_set key $__form $__form_counter_i]

    # This is the value
    set __form_input [ns_set value $__form $__form_counter_i]
    if { [info exists --form_input_arr($__form_key) ] } {
        if { $__form_input ne $__form_input_arr($__form_key) } {
            # which one is correct? log error
            ns_log Error "paypal-thankyou.tcl: form input error. duplcate key provided for ${__form_key}"
            ad_script_abort
        } else {
            ns_log Notice "paypal-thankyou.tcl: notice, form has two keys with same info.."
        }
    } else {
        set __form_input_arr($__form_key) [ns_set value $__form $__form_counter_i]
    }
}

# filter out variables not explicitly requested?

# build new form? would also need __form_input_type(key,attribute), where attribute is type,maxlength, accesskey, alt, id, class, size, style, size
# formbuilder specs: order, item#
# how to specify multi input select, box and radio inputs and form order?

if { [info exists __form_input_arr(invoice)] } {
    set order_id [string trim [string range 9 end]]
    # set order to confirmed state.
    if { [info exists __form_input_arr(txn_id)] } {
        set trans_id $__form_input_arr(txn_id) 
        #call state change here.
        db_transaction {
          db_dml change_cart_state "update ec_orders 
      set order_state='confirmed', confirmed_date=current_timestamp
      where order_id=:order_id"
        }
        ns_log Notice "paypal-thankyou.tcl,ref(186) order_id $order_id now in confirmed state."
        # we really cannot convert beyond that for Paypal Web Standard edition
    }
}
ad_returnredirect "[ec_url]"
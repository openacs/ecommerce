#  www/ecommerce/review-submit.tcl
ad_page_contract {
    @param product_id
    @param usca_p
    @author
    @creation-date
    @cvs-id review-submit.tcl,v 3.2.2.6 2000/08/18 21:46:35 stevenp Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    product_id:integer
    usca_p:optional
}

# we need them to be logged in
set user_id [ad_verify_and_get_user_id]

if {$user_id == 0} {
    
    # The following line has been commented because only product_id is available.
    # set return_url "[ad_conn url]?[export_url_vars product_id prev_page_url prev_args_list]"

    # if [info exists usca_p] {
    #    set return_url "[ad_conn url]?[export_url_vars product_id usca_p]"
    # } else {
    #    set return_url "[ad_conn url]?[export_url_vars product_id usca_p]"
    # }	

    set return_url "[ad_conn url]?[export_url_vars product_id usca_p]"

    ad_returnredirect "/register?[export_url_vars return_url]"
    return
}

# user session tracking
set user_session_id [ec_get_user_session_id]

ec_create_new_session_if_necessary [export_entire_form_as_url_vars]
# type2

ec_log_user_as_user_id_for_this_session

set product_name [db_string get_product_name "select product_name from ec_products where product_id=:product_id"]

# not clear where this is used, but I'll leave it in because it's not really clear how this code is put together.
lappend altered_prev_args_list $product_name

set rating_widget [ec_rating_widget]
db_release_unused_handles
ec_return_template



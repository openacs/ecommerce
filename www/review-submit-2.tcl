#  www/ecommerce/review-submit-2.tcl
ad_page_contract {
    @param product_id:integer
    @param rating
    @param one_line_summary
    @param user_comment
    @param usca_p:optional
  @author
  @creation-date
  @cvs-id review-submit-2.tcl,v 3.3.2.8 2000/08/18 21:46:35 stevenp Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    product_id:integer
    rating:notnull
    one_line_summary
    user_comment:notnull
    usca_p:optional
}

# we need them to be logged in
set user_id [ad_verify_and_get_user_id]

if {$user_id == 0} {
    
    set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"

    ad_returnredirect "/register?[export_url_vars return_url]"
    return
}

set exception_text ""
set exception_count 0

if { ![info exists rating] || [empty_string_p $rating] } {
    append exception_text "<li>Please select a rating for the product.\n"
    incr exception_count
}

if { $exception_count > 0 } {
    ad_return_complaint $exception_count $exception_text
    return
}

# user session tracking
set user_session_id [ec_get_user_session_id]

ec_create_new_session_if_necessary [export_entire_form_as_url_vars]
# type2

db_1row get_product_and_user_info "
    select product_name,
           ec_product_comment_id_sequence.nextval as comment_id,
           user_email,
           to_char(sysdate,'Day Month DD, YYYY') as current_date
    from ec_products,
         (select email as user_email
          from   cc_users
          where  user_id = :user_id)
    where product_id=:product_id
"

set hidden_form_variables [export_form_vars product_id rating one_line_summary user_comment comment_id]

set review_as_it_will_appear "<b><a href=\"/shared/community-member?[export_url_vars user_id]\">$user_email</a></b> 
rated this product  
[ec_display_rating $rating] on <i>$current_date</i> and wrote:<br>
<b>$one_line_summary</b><br>
[ec_display_as_html $user_comment]
"

set system_name [ad_system_name]
db_release_unused_handles
ec_return_template


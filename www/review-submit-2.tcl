ad_page_contract {

    @param product_id:integer
    @param rating
    @param one_line_summary
    @param user_comment
    @param usca_p:optional

    @author
    @creation-date
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    product_id:integer
    rating:notnull
    one_line_summary
    user_comment:notnull
    usca_p:optional
}

# we need them to be logged in
set user_id [ad_conn user_id]
if {$user_id == 0} {
    set return_url "[ad_conn url]?[export_entire_form_as_url_vars]"
    ad_returnredirect "/register?[export_url_vars return_url]"
    ad_script_abort
}

set exception_text ""
set exception_count 0

if { ![info exists rating] || [empty_string_p $rating] } {
    append exception_text "<li>Please select a rating for the product.\n"
    incr exception_count
}

if { $exception_count > 0 } {
    ad_return_complaint $exception_count $exception_text
    ad_script_abort
}

# user session tracking

set user_session_id [ec_get_user_session_id]
ec_create_new_session_if_necessary [export_entire_form_as_url_vars]

db_1row get_product_and_user_info "
    select product_name,
           ec_product_comment_id_sequence.nextval as comment_id,
           user_email,
           to_char(sysdate,'Day Month DD, YYYY') as current_date
    from ec_products,
         (select email as user_email
          from   cc_users
          where  user_id = :user_id)
    where product_id=:product_id"

set hidden_form_variables [export_form_vars product_id rating one_line_summary user_comment comment_id]

set review_introduction "
<b><a href=\"/shared/community-member?[export_url_vars user_id]\">$user_email</a></b> 
rated this product  
[ec_display_rating $rating] on <i>$current_date</i> and wrote:<br>"

set system_name [ad_system_name]
set context_bar [template::adp_parse [acs_root_dir]/packages/[ad_conn package_key]/www/contextbar [list context_addition [list "Check Your Review"]]]
set ec_system_owner [ec_system_owner]

db_release_unused_handles
ad_return_template

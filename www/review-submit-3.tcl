#  www/ecommerce/review-submit-3.tcl
ad_page_contract {
    @param product_id
    @param rating
    @param one_line_summary
    @param user_comment
    @param comment_id
    @param usca_p:optional
  @author
  @creation-date
  @cvs-id review-submit-3.tcl,v 3.2.2.6 2000/08/18 21:46:35 stevenp Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    product_id:integer
    rating
    one_line_summary
    user_comment
    comment_id:integer
    usca_p:optional
}



# we need them to be logged in
set user_id [ad_verify_and_get_user_id]

if {$user_id == 0} {

    # The following code was here before, but I am commenting it out because I can find no definition of prev_page_url, prev_args_list, et al, in the entire acs code tree.
    # set return_url "[ad_conn url]?[export_url_vars product_id prev_page_url prev_args_list altered_prev_args_list rating one_line_summary user_comment comment_id]"
    
    if [info exists usca_p] {
	set return_url "[ad_conn url]?[export_url_vars product_id rating one_line_summary user_comment comment_id usca_p]"
    } else {
	set return_url "[ad_conn url]?[export_url_vars product_id rating one_line_summary user_comment comment_id]"
    }
   
    ad_returnredirect "/register?[export_url_vars return_url]"
    return
}

# user session tracking
set user_session_id [ec_get_user_session_id]

ec_create_new_session_if_necessary [export_entire_form_as_url_vars]
# type2

# see if the review is already in there, meaning they pushed reload,
# in which case, just show the thank you message, otherwise insert the
# review

db_1row product_name_and_double_click_check "
select product_name,
       comment_found_p
from   ec_products,
       (select count(*) as comment_found_p
        from   ec_product_comments
        where  comment_id = :comment_id)
where  product_id = :product_id
"

if { !$comment_found_p } {

    set ns_conn_peeraddr [ns_conn peeraddr]

    db_dml insert_new_comment "
    insert into ec_product_comments
    (comment_id, product_id, user_id, user_comment, one_line_summary,
     rating, comment_date, last_modified, last_modifying_user, modified_ip_address)
    values
    (:comment_id, :product_id, :user_id, :user_comment, :one_line_summary,
     :rating, sysdate, sysdate, :user_id, :ns_conn_peeraddr)
"
}

set comments_need_approval [ad_parameter -package_id [ec_id] ProductCommentsNeedApprovalP]
set system_owner_email [ec_system_owner]
set product_link "product?[export_url_vars product_id]"
db_release_unused_handles
ec_return_template
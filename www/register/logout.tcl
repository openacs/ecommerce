# /www/register/logout.tcl

ad_page_contract {
    Logs a user out

    @cvs-id $Id$

} {
    
}

ad_user_logout 
# expires the user_session_id for ecommerce
ec_user_session_logout
db_release_unused_handles

ad_returnredirect "/"


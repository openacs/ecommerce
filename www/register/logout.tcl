# /www/register/logout.tcl

ad_page_contract {
    Logs a user out

    @cvs-id logout.tcl,v 1.2 2000/09/19 07:24:19 ron Exp

} {
    
}

ad_user_logout 
# expires the user_session_id for ecommerce
ec_user_session_logout
db_release_unused_handles

ad_returnredirect "/"


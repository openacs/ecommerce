# /www/register/bad-password.tcl

ad_page_contract {
    Informs the user that they have typed in a bad password.
    @cvs-id bad-password.tcl,v 1.2 2000/09/19 07:24:15 ron Exp
} {
    {user_id:naturalnum}
    {return_url ""}
} -properties {
    system_name:onevalue
    email_forgotten_password_p:onevalue
    user_id:onevalue
}

set email_forgotten_password_p [ad_parameter EmailForgottenPasswordP security 1]

set system_name [ad_system_name]

ad_return_template
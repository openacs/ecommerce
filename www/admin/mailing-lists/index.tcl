ad_page_contract {
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

set title "Mailing Lists"
set context [list $title]

set mailing_list_widget_html "[ec_mailing_list_widget "f"]"

set category_widget_html "[ec_category_widget]"

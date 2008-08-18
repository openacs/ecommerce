# add.tcl
ad_page_contract {
    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

set title "Add Email Template"
set context [list [list index "Email Templates"] $title]

set issue_type_widget_html [ec_issue_type_widget]

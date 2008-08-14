ad_page_contract {

    Add a custom product field.

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date May 2002

} {
}

ad_require_permission [ad_conn package_id] admin

set title "Add a Custom Field"
set context [list [list index Products] $title]

set custom_field_type_html [ec_column_type_widget]

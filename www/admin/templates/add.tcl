#  www/[ec_url_concat [ec_url] /admin]/templates/add.tcl
ad_page_contract {
    @param based_on optional to base template on

  @author
  @creation-date
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    based_on:optional
}

ad_require_permission [ad_conn package_id] admin

set title  "Add a Template"
set context [list [list index "Product Templates"] $title]

if { [info exists based_on] && ![empty_string_p $based_on] } {
    set template [db_string get_template "select template from ec_templates where template_id=:based_on"]
} else {
    set template ""
}

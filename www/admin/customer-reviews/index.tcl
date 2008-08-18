# index.tcl
ad_page_contract {
    @author
    @creation-date
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

set title "Customer Reviews"
set context [list $title]

set requires_approval [parameter::get -package_id [ec_id] -parameter ProductCommentsNeedApprovalP -default 1]

set sql "select approved_p, count(*) as n_reviews
from ec_product_comments
group by approved_p
order by approved_p desc"

set approved_reviews_html ""
db_foreach get_approved_reviews $sql {
    if [empty_string_p $approved_p] {
        set passthrough_approved_p "null"
        set anchor_value "Not Yet Approved/Disapproved Customer Reviews"
    } elseif { $approved_p == "t" } {
        set passthrough_approved_p "t"
        set anchor_value "Approved Reviews"
    } elseif { $approved_p == "f" } {
        set passthrough_approved_p "f"
        set anchor_value "Disapproved Reviews"
    } else {
        ns_log Error "[ec_url_concat [ec_url] /admin]/customer-reviews/index.tcl found unrecognized approved_p value of \"$approved_p\""
        # note that we'll probably also get a Tcl error below
    }
    append approved_reviews_html "<li><a href=\"index-2?approved_p=$passthrough_approved_p\">$anchor_value</a> ($n_reviews)</li>\n"
}

set table_names_and_id_column [list ec_product_comments ec_product_comments_audit comment_id]

set audit_url "[ec_url_concat [ec_url] /admin]/audit-tables?[export_url_vars table_names_and_id_column]"

db_release_unused_handles

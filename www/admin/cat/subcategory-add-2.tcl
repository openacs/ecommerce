# /www/[ec_url_concat [ec_url] /admin]/cat/subcategory-add-2.tcl

ad_page_contract {

    Inserts the subcategory.

    @param category_name the name of the category
    @param category_id the ID of the category
    @param subcategory_name the name of the new subcategory
    @param subcategory_id the ID of the subcategory
    @param next_sort_key the next sort key must be a number
    @param prev_sort_key the previous sort key must be a number

    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    category_name:notnull
    category_id:integer,notnull
    subcategory_name:trim,notnull
    subcategory_id:integer,notnull
    prev_sort_key:notnull
    next_sort_key:notnull
}

ad_require_permission [ad_conn package_id] admin

# we need them to be logged in
set user_id [ad_verify_and_get_user_id]

if {$user_id == 0} {
    
    set return_url "[ad_conn url]?[export_url_vars category_name category_id subcategory_name subcategory_id]"

    ad_returnredirect "/register?[export_url_vars return_url]"
    return
}

# see first whether they already entered this subcategory (in case they
# pushed submit twice), in which case, just redirect to 
# category.tcl



if { [db_0or1row sub_id_select "select subcategory_id from ec_subcategories
where subcategory_id=:subcategory_id"] == 1} {
    ad_returnredirect "category?[export_url_vars category_id category_name]"
    return
}

# now make sure there's no subcategory in this category with that sort key already

db_transaction {
    ### gilbertw - added do the calculation outside of the db.  	
    #   PostgreSQL encloses the bind variables in ' '
    #  where sort_key = (:prev_sort_key + :next_sort_key)/2
    set sort_key [expr ($prev_sort_key + $next_sort_key)/2]

    set n_conflicts [db_string get_n_conflicts "select count(*)
from ec_subcategories
where category_id=:category_id
and sort_key = :sort_key"]
    if { $n_conflicts > 0 } {
	ad_return_complaint 1 "<li>The $category_name page appears to be out-of-date;
	perhaps someone has changed the subcategories since you last reloaded the page.
	Please go back to <a href=\"category?[export_url_vars category_id category_name]\">the $category_name page</a>, push
	\"reload\" or \"refresh\" and try again."
	return
    }
    set address [ns_conn peeraddr]
    db_dml ec_subcat_insert "insert into ec_subcategories
    (category_id, subcategory_id, subcategory_name, sort_key, last_modified, last_modifying_user, modified_ip_address)
    values
    (:category_id, :subcategory_id, :subcategory_name, :sort_key, sysdate, :user_id, :address)"

} on_error {
    db_release_unused_handles
    ad_return_complaint 1 "Sorry, we couldn't perform your dml request."
    return
}

db_release_unused_handles

ad_returnredirect "category?[export_url_vars category_id category_name]"

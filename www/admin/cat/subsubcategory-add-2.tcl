# /www/[ec_url_concat [ec_url] /admin]/cat/subsubcategory-add-2.tcl
ad_page_contract  {

    Actually created subsubcategory of given subcategory.

    @param category_name the category name 
    @param category_id the category ID
    @param subcategory_name the subcategory name
    @param subcategory_id the subcategory ID
    @param subsubcategory_name the new Name
    @param subsubcategory_id the new ID
    @param prev_sort_key the previous sort key
    @param next_sort_key the next sort key

    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    category_name:notnull
    category_id:integer,notnull
    subcategory_name:notnull
    subcategory_id:integer,notnull
    subsubcategory_name:trim,notnull
    subsubcategory_id:integer,notnull
    prev_sort_key:notnull
    next_sort_key:notnull
}

ad_require_permission [ad_conn package_id] admin

# we need them to be logged in
set user_id [ad_verify_and_get_user_id]

if {$user_id == 0} {
    
    set return_url "[ad_conn url]?[export_url_vars category_name category_id subcategory_name subcategory_id subsubcategory_name subsubcategory_id]"

    ad_returnredirect "/register?[export_url_vars return_url]"
    ad_script_abort
}

# see first whether they already entered this subsubcategory (in case they
# pushed submit twice), in which case, just redirect to 
# subcategory.tcl



if { [db_0or1row get_subcat_id "select subsubcategory_id from ec_subsubcategories
where subsubcategory_id=:subsubcategory_id"] ==1} {


    ad_returnredirect "subcategory?[export_url_vars category_id category_name subcategory_id subcategory_name]"
    ad_script_abort
}

# now make sure there's no subsubcategory in this subcategory with that sort key already

### gilbertw - added do the calculation outside of the db.  PostgreSQL encloses
#   the bind variables in ' '
#  where sort_key = (:prev_sort_key + :next_sort_key)/2
set sort_key [expr ($prev_sort_key + $next_sort_key)/2]

set n_conflicts [db_string get_n_conflicts "select count(*)
from ec_subsubcategories
where subcategory_id=:subcategory_id
and sort_key = :sort_key"]

if { $n_conflicts > 0 } {
    ad_return_complaint 1 "<li>The $subcategory_name page appears to be out-of-date;
    perhaps someone has changed the subcategories since you last reloaded the page.
    Please go back to <a href=\"subcategory?[export_url_vars subcategory_id subcategory_name category_id category_name]\">the $subcategory_name page</a>, push
    \"reload\" or \"refresh\" and try again."
    ad_script_abort
}

set address [ns_conn peeraddr]
db_dml insert_ec_subsubcat "insert into ec_subsubcategories
(subcategory_id, subsubcategory_id, subsubcategory_name, sort_key, last_modified, last_modifying_user, modified_ip_address)
values
(:subcategory_id, :subsubcategory_id, :subsubcategory_name, :sort_key, sysdate, :user_id,:address)"

ad_returnredirect "subcategory?[export_url_vars category_id category_name subcategory_id subcategory_name]"
ad_script_abort




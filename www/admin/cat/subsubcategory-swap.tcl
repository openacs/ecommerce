# /www/[ec_url_concat [ec_url] /admin]/cat/subsubcategory-swap.tcl
ad_page_contract {

    Swaps ordering of two adjacent subsubcategories of the same subcategory.

    @param category_id the category ID
    @param category_name the category name
    @param subcategory_id the subcategory ID
    @param subcategory_name the subcategory name
    @param subsubcategory_id the subsubcategory new name
    @param next_subsubcategory_id the next subsubcategory ID
    @param sort_key the sort key
    @param next_sort_key the next sort key

    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    subsubcategory_id:integer,notnull
    next_subsubcategory_id:integer,notnull
    sort_key:notnull
    next_sort_key:notnull
    category_id:integer,notnull
    category_name:notnull
    subcategory_id:integer,notnull
    subcategory_name:notnull
}

ad_require_permission [ad_conn package_id] admin

# switches the ordering of a category with that of the next subsubcategory

set item_match [db_string get_item_match_no "select count(*) from ec_subsubcategories where subsubcategory_id=:subsubcategory_id and sort_key=:sort_key"]

set next_item_match [db_string get_next_item_match "select count(*) from ec_subsubcategories where subsubcategory_id=:next_subsubcategory_id and sort_key=:next_sort_key"]

if { $item_match != 1 || $next_item_match != 1 } {
    ad_return_complaint 1 "<li>The page you came from appears to be out-of-date;
    perhaps someone has changed the subsubcategories since you last reloaded the page.
    Please go back to the previous page, push \"reload\" or \"refresh\" and try
    again."
    return
}

db_transaction {
db_dml update_ec_subsubcat "update ec_subsubcategories set sort_key=:next_sort_key where subsubcategory_id=:subsubcategory_id"
db_dml update_ec_subsubcat_2 "update ec_subsubcategories set sort_key=:sort_key where subsubcategory_id=:next_subsubcategory_id"
}
db_release_unused_handles

ad_returnredirect "subcategory?[export_url_vars category_id category_name subcategory_id subcategory_name]"

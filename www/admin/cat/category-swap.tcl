# /www/[ec_url_concat [ec_url] /admin]/cat/category-swap.tcl

ad_page_contract {

    Switches the ordering of a category with that of the next category.

    @param category_id the ID for the category
    @param next_category_key the key for next category
    @param sort_key the sort key
    @param next_sort_key the next sort key

    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {

    category_id:integer,notnull
    next_category_id:integer,notnull
    sort_key:notnull
    next_sort_key:notnull
}

ad_require_permission [ad_conn package_id] admin

# check that the sort keys are the same as before; otherwise the page
# they got here from is out of date

set item_match [db_string get_item_match_count "select count(*) from ec_categories where category_id=:category_id and sort_key=:sort_key"]

set next_item_match [db_string get_next_item_match_count "select count(*) from ec_categories where category_id=:next_category_id and sort_key=:next_sort_key"]

if { $item_match != 1 || $next_item_match != 1 } {
    ad_return_complaint 1 "<li>The page you came from appears to be out-of-date;
    perhaps someone has changed the categories since you last reloaded the page.
    Please go back to the previous page, push \"reload\" or \"refresh\" and try
    again."
    return
}

db_transaction {
    db_dml update_swap_cat_1 "update ec_categories set sort_key=:next_sort_key where category_id=:category_id"
    db_dml update_swap_cat_2 "update ec_categories set sort_key=:sort_key where category_id=:next_category_id"
}
db_release_unused_handles

ad_returnredirect "index"

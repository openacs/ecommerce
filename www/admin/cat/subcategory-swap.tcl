# /www/[ec_url_concat [ec_url] /admin]/cat/subcategory-swap.tcl
ad_page_contract {

    Swaps two adjacent subcategories of common category.

    @param subcategory_id the subcategory ID
    @param next_subcategory_id the next subcategory ID (to swap)
    @param sort_key the key to sort this one on
    @param next_sort_key the key for the other
    @param category_id the category ID
    @param category_name the category name

    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    subcategory_id:integer,notnull
    next_subcategory_id:integer,notnull
    sort_key:notnull
    next_sort_key:notnull
    category_id:integer,notnull
    category_name:notnull
}

ad_require_permission [ad_conn package_id] admin

# switches the ordering of a category with that of the next subcategory



set item_match [db_string get_item_match "select count(*) from ec_subcategories where subcategory_id=:subcategory_id and sort_key=:sort_key"]

set next_item_match [db_string get_next_item_match "select count(*) from ec_subcategories where subcategory_id=:next_subcategory_id and sort_key=:next_sort_key"]

if { $item_match != 1 || $next_item_match != 1 } {
    ad_return_complaint 1 "<li>The page you came from appears to be out-of-date;
    perhaps someone has changed the subcategories since you last reloaded the page.
    Please go back to the previous page, push \"reload\" or \"refresh\" and try
    again."
    return
}

db_transaction {
db_dml update_swap_subcat "update ec_subcategories set sort_key=:next_sort_key where subcategory_id=:subcategory_id"
db_dml update_swap_subcat_2 "update ec_subcategories set sort_key=:sort_key where subcategory_id=:next_subcategory_id"
}
db_release_unused_handles
ad_returnredirect "category?[export_url_vars category_id category_name]"

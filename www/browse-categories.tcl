ad_page_contract {

    Present a list of top level product categories to browse.

    @author Bart Teeuwisse <bart.teeuwisse@7-sisters.com>
    @creation-date September 2002
    @cvs_id

} {
}

template::query get_categories categories multirow "select category_id as id, category_name as name from ec_categories order by sort_key" -eval {
    set row(url) "category-browse?category_id=$row(id)"
}

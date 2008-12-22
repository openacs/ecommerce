# generate list of lists for code in ecommerce/lib

# @param base_url is url for page (required)
# @param item_count (required)
# @param items_per_page (required)
# @param this_start_row (required) the start row for this page
# @param separator is html used between page numbers, defaults to &nbsp;

if { ![info exists separator] } {
    set separator "&nbsp;"
}

set bar_list_set [ecds_pagination_by_items $item_count $items_per_page $this_start_row]
set prev_bar $separator
set next_bar $separator


set prev_bar_list [lindex $bar_list_set 0]
foreach {page_num start_row} $prev_bar_list {
    lappend prev_bar " <a href=\"${base_url}${start_row}\">${page_num}</a> "
} 
set prev_bar [join $prev_bar $separator]

set current_bar_list [lindex $bar_list_set 1]
set current_bar "[lindex $current_bar_list 0]"

set next_bar_list [lindex $bar_list_set 2]
foreach {page_num start_row} $next_bar_list {
    append next_bar " <a href=\"${base_url}${start_row}\">${page_num}</a> "
}
set next_bar [join $next_bar $separator]

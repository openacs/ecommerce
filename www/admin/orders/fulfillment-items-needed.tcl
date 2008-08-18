#  www/[ec_url_concat [ec_url] /admin]/orders/fulfillment-items-needed.tcl
ad_page_contract {
  Items needed for fulfillment.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
}

ad_require_permission [ad_conn package_id] admin

set title "Items Needed"
set context [list [list index "Orders / Shipments / Refunds"] $title]

set items_needed_select_html ""
db_foreach items_needed_select "select p.product_id, p.product_name,
           i.color_choice, i.size_choice, i.style_choice,
           count(*) as quantity
      from ec_products p, ec_items_shippable i
     where p.product_id=i.product_id
  group by p.product_id, p.product_name,
           i.color_choice, i.size_choice, i.style_choice
  order by quantity desc" {
      set option_list [list]
      if { ![empty_string_p $color_choice] } {
          lappend option_list "Color: $color_choice"
      }
      if { ![empty_string_p $size_choice] } {
          lappend option_list "Size: $size_choice"
      }
      if { ![empty_string_p $style_choice] } {
          lappend option_list "Style: $style_choice"
      }
      set options [join $option_list ", "]
      
      append items_needed_select_html "<tr><td align=right>$quantity</td><td><a href=\"[ec_url_concat [ec_url] /admin]/products/one?[export_url_vars product_id]\">$sku</a></td><td><a href=\"[ec_url_concat [ec_url] /admin]/products/one?[export_url_vars product_id]\">$product_name</a>[ec_decode $options "" "" "; $options"]</td></tr>\n"
}


#sitemap.xml.tcl

set cache_product_as_file [parameter::get -parameter CacheProductAsFile -default 0]
set sitemap_xml "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n"

if { $cache_product_as_file } {

    set sitemap_list [db_list_of_lists get_catalog_sku_products "
      select b.site_url as site_url, a.last_modified as last_modified from ec_products a, ecds_product_id_site_url_map b
        where a.product_id = b.product_id and a.active_p='t' and a.present_p = 't' and b.site_url is not null
        order by a.last_modified desc limit 10000"]

    foreach url_set $sitemap_list {
        set site_url [lindex $url_set 0]
        set last_modified [lindex $url_set 1]
        set url "[ec_insecure_location][ec_url]${site_url}"

        set last_mod ""
        regsub -- { } $last_modified {T} last_mod
        append last_mod ":00"
        append sitemap_xml "<url><loc>$url</loc><lastmod>${last_mod}</lastmod></url>\n"
    }

} else {

    set sitemap_list [db_list_of_lists get_catalog_products "
      select product_id, last_modified from ec_products
        where active_p='t' and present_p = 't' 
        order by last_modified desc"]

    foreach url_pair $sitemap_list {
        set product_id [lindex $url_pair 0]
        set last_modified [lindex $url_pair 1]
        set url "[ec_insecure_location][ec_url]product?usca_p=t&amp;product_id=${product_id}"
        set last_mod ""
        regsub -- { } $last_modified {T} last_mod
        append last_mod ":00"
        append sitemap_xml "<url><loc>$url</loc><lastmod>${last_mod}</lastmod></url>\n"
    }
}

append sitemap_xml "</urlset>\n"
ns_return 200 text/xml $sitemap_xml

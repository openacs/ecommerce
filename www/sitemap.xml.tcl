#sitemap.xml.tcl

set sitemap_xml "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n"
set sitemap_list [db_list_of_lists get_catalog_products "select product_id, last_modified from ec_products where active_p='t' and present_p = 't' order by last_modified desc limit 100"]

foreach url_pair $sitemap_list {
    set product_id [lindex $url_pair 0]
    set last_modified [lindex $url_pair 1]
    set url "[ec_insecure_location][ec_url]product?usca_p=t%26product_id=${product_id}"
    set last_mod ""
    regsub -- { } $last_modified {T} last_mod
    append last_mod ":00"
    append sitemap_xml "<url><loc>$url</loc><lastmod>${last_mod}</lastmod></url>\n"
}
append sitemap_xml "</urlset>\n"
ns_return 200 text/xml $sitemap_xml
ns_log Notice "ecommerce/www/sitemap.xml.tcl: returning $sitemap_xml"
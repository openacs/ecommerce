ad_proc ec_products__datasource {
    object_id
} {
    @author Gilbert Wong
    @author Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
} {
    db_0or1row ec_products_datasource {
        select e.product_id as object_id,
               e.product_name as title,
               e.detailed_description as content,
               'text/plain' as mime,
               e.search_keywords as keywords,
               'text' as storage_type
        from ec_products e
        where e.product_id = :object_id
    } -column_array datasource

    return [array get datasource]
}


ad_proc ec_products__url {
    object_id
} {
    @author Gilbert Wong
} {

    set package_id [apm_package_id_from_key ecommerce]
    db_1row get_url_stub "
        select site_node__url(node_id) as url_stub
        from site_nodes
        where object_id=:package_id
    "

    set url "${url_stub}/product?product_id=$object_id"

    return $url
}



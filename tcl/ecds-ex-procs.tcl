ad_library {
    Vendor specific customization utilities
    This file is a crude example, which requires coding for each vendor
    One ecds-N-procs.tcl file per vendor, where N is an abbreviation that identifies the vendor

    procs should return "ERROR" when critical info is unavailable
    procs should return empty string for noncritical info

    @creation-date  May 2009

}

ad_proc -private ecdsii_ex_product_url_from_vendor_sku {
    vendor_sku
} {
    returns vendor's url of product or empty string
} {
    set url ""
    return $url
}

ad_proc -private ecdsii_ex_no_shipping_avail_p {
    page
} {
    returns no_shipping_avail_p for item.
    defaults to "f". In the future, this should check against an existing shipping status on vendor's page
} {
    return "f"
}

ad_proc -private ecdsii_ex_ec_shipping {
    page
} {
    returns shipping cost for first item.
    For now, returning blank, because we want shipping-cost based on shipping weight.
} {
    return ""
}

ad_proc -private ecdsii_ex_ec_shipping_additional {
    page
} {
    returns shipping cost for each additional quantity of item.
    For now, returning blank, because we want shipping-cost based on shipping weight.
} {
    return ""
}

ad_proc -private ecdsii_ex_product_url {
    page
} {
    returns product url for vendor's item.
    For now, returning blank, but we could point to the vendor's website etc if we wanted
} {
    return ""
}

ad_proc -private ecdsii_ex_product_image_url { 
    vendor_page
} {
    returns url of vendor's product image on vendor's website
} {
    #set image_url from image_name
    set image_name ""
    set image_url ""
    return $image_url
}

ad_proc -private ecdsii_ex_vendor_sku_from_page {
    page
} {
    returns vendor_sku of vendor's product page
} {
    # get the vendor_sku from vendor's page content
    set vendor_sku $page
    return $vendor_sku
}

ad_proc -private ecdsii_ex_units {
    page
} {
    reurns unit of measure from content of a vendor's product page
} {
    set unit_of_measure $page
    return $unit_of_measure
}

ad_proc -private ecdsii_ex_unit_price {
    page
} {
    reurns unit_price from content of a vendor's product page
} {
    set unit_price $page
    return $unit_price
}

ad_proc -private ecdsii_ex_brand_name {
    page
} {
    returns brand_name from content of a vendor's product page
} {
    set brand_name $page
    return $brand_name
}

ad_proc -private ecdsii_ex_brand_model_number {
    page
} {
    returns brand_model_number from content of a vendor's product page
} {
    set mfg_model_number $page
    return $mfg_model_number
}

ad_proc -private ecdsii_ex_min_ship_qty {
    page
} {
    returns minimum shipping quantity from content of a vendor's product page, defaults to 1
} {
    set minimum_shipping_quantity $page
    return $minimum_shipping_quantity
}

ad_proc -private ecdsii_ex_ship_weight {
    page
} {
    returns shipping weight for one unit from content of a vendor's product page
} {
    set ship_weight $page
    return $ship_weight
}

ad_proc -private ecdsii_ex_stock_status {
    page
} {
    returns stock_status for one unit from content of a vendor's product page
} {
    set stock_status $page
    return $stock_status
}

ad_proc -private ecdsii_ex_short_description {
    page
} {
    returns short_description from content of a vendor's product page
} {
    set short_description $page
    return $short_description
}

ad_proc -private ecdsii_ex_long_description {
    page
} {
    returns long_description from content of a vendor's product page
} {
    set long_description $page
    return $long_description
}

ad_proc -private ecdsii_ex_product_name {
    page
} {
    returns product_name from content of a vendor's product page
} {
    set product_name $page
    return $product_name
}

ad_proc -private ecdsii_ex_product_sku {
    brand_name
    brand_model_number
    {sku ""}
} {
    returns sku from content of a vendor's product page
} {
    set new_sku  "{$brand_name}${brand_model_number}"
    return $new_sku
}

ad_proc -private ecdsii_ex_one_line_description {
    page
} {
    returns one_line_description from content of a vendor's product page
} {
    set one_line_description $page
    return $one_line_description
}

ad_proc -private ecdsii_ex_detailed_description {
    page
} {
    returns detailed_description from content of a vendor's product page
} {
    set description $page
    return $description
}

ad_proc -private ecdsii_ex_sales_description {
    page
} {
    returns sales_description from content of a vendor's product page
} {
    set sales_description_html $page
    return $sales_description_html
}

ad_proc -private ecdsii_ex_web_comments {
    page
} {
    returns comments about product from content of a vendor's product page
} {
    set notes_restrictions $page
    return $notes_restrictions
}

ad_proc -private ecdsii_ex_product_options {
    page
} {
    returns options about product from content of a vendor's product page
} {
    return ""    
}

ad_proc -private ecdsii_ex_unspsc_code {
    page
} {
    returns UNSPSC code about product from content of a vendor's product page
} {
   set unspsc_code ""
   return $unspsc_code
}

ad_proc -private ecdsii_ex_category_id_list {
    page
} {
    returns list of category_ids from content of a vendor's product page
} {
    return [list]
}


ad_proc -private ecdsii_ex_subcategory_id_list {
    page
} {
    returns list of subcategory_ids from content of a vendor's product page
} {
upvar category_id_list category_id_list

    set subcategory_id_list [list]
    return $subcategory_id_list
}

ad_proc -private ecdsii_ex_subsubcategory_id_list {
    page
} {
    returns list of subsubcategory_ids from content of a vendor's product page
} {
    return [list]
}

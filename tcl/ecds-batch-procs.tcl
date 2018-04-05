ad_library {

    batch procs for ecds_ Customization utilities for maintaining product data in ecommerce module.

    @creation-date  March 2009
    
    uses ecds_process_control as permissions style process control.
    see ecds-procs.tcl for other requirements
    procs in this file are separated from other procs in ecds-procs for dynamic re-loading of small changes during process runs.

}


ad_proc -private ecds_product_id_from_path {
    product_path
} {
    returns the product_id from the site's product_url (unique portion of the local url (after ec_url)) for the product derived from ecommerce/www/index.vuh, or -1 if  product_url not found
} {
    # we cache the query because this should return a fairly constant value and hopefully will be called repeatedly
    db_0or1row -cache_key "ec-ds-id-site-url-${product_path}" get_product_id_from_filepath_tail "select product_id from ecds_product_id_site_url_map where site_url = :product_path"
    if { ![info exists product_id] } {
        set product_id -1
    }
    return $product_id
}

ad_proc -private ecds_process_control_check {
    {process_ref ""}
    {ref_type ""}
} {
    returns the status or okay_to_start (1/0) for ecds_process process_ref
} {

    switch -exact -- $ref_type {
        okay_to_start {
            db_0or1row get_process_control_okay_to_start {select okay_to_start as return_value from ecds_process_control where process_ref = :process_ref }
        }
        status {
            db_0or1row get_process_control_status {select status as return_value from ecds_process_control where process_ref = :process_ref }
        }
        default {
            ns_log Warning "ecds_process_control_check: bad reference type $ref_type provided by calling procedure, process_ref = ${process_ref}"
            set return_value ""
        }
    }
    if { ![info exists return_value] } {
        # return value appropriate to ref_type
        if { $ref_type eq "okay_to_start" } {
            # not okay to start if process not found
            set return_value 0
        } else {
            set return_value ""
        }
    } 
    if { $ref_type eq "okay_to_start" } {
        if {$return_value } {
            set return_value 1
        } else {
            set return_value 0
        }
    } 
}

ad_proc -private ecds_refresh_import_products_from_vendor {
    vendor_abbrev
} {
    creates or updates product info for imported products of a specific vendor
} {
    # we break this into two queries in order to process products with minshipqty > 1 first
    # because those products may also have pricing breakdown in their one_line_description
    # and null values of minshipqty are returned before numeric values

    set vendor_product_ids_list [db_list_of_lists get_vendor_product_ids_minship "
        select product_id from ec_custom_product_field_values
        where vendorabbrev = :vendor_abbrev and minshipqty is not null order by minshipqty desc"]
    lappend vendor_product_ids_list [db_list_of_lists get_vendor_product_ids_null_minship "
        select product_id from ec_custom_product_field_values
        where vendorabbrev = :vendor_abbrev and minshipqty is null"]
    set product_count [llength $vendor_product_ids_list]
    foreach product_id $vendor_product_ids_list {
        ecds_import_product_from_vendor_site $vendor_abbrev product_id $product_id
    }
}

ad_proc -private ecds_create_cache_product_files {
} {
    creates or updates the static pages of active products
} {

    set cache_product_as_file [parameter::get -parameter CacheProductAsFile -default 0]
    ns_log Notice "ecds_create_cache_product_files: starting.."
    if { $cache_product_as_file } {
        # we break this into two queries in order to process products with minshipqty > 1 first
        # because those products may also have pricing breakdown in their one_line_description
        # and c.minshipqty is null is programmatically greater than numeric values
        set active_product_list [db_list_of_lists get_catalog_product_ids_w_minshipqty "
      select a.product_id from ec_products a, ec_custom_product_field_values c
        where a.product_id = c.product_id and a.active_p='t' and a.present_p = 't' and a.sku is not null and c.minshipqty is not null
        order by c.minshipqty desc, a.last_modified desc"]

        foreach product_id $active_product_list {
            ecds_file_cache_product $product_id
        }

        set active_product_list [db_list_of_lists get_catalog_product_ids_wo_minship "
      select a.product_id from ec_products a, ec_custom_product_field_values c
        where a.product_id = c.product_id and a.active_p='t' and a.present_p = 't' and a.sku is not null and c.minshipqty is null
        order by c.minshipqty desc, a.last_modified desc"]

        foreach product_id $active_product_list {
            ecds_file_cache_product $product_id
        }

    }
    ns_log Notice "ecds_create_cache_product_files: ended"
}


ad_proc -private ecds_create_product_site_urls {
    {calc_sku 0}
} {
    creates or updates the static page references (ecds_product_id_site_url_map.site_url) of active products, recalculates product sku if calc_sku is supplied as 1.
} {
    set cache_product_as_file [parameter::get -parameter CacheProductAsFile -default 0]
    ns_log Notice "ecds_create_product_site_urls: starting..  cache_product_as_file ${cache_product_as_file}"
    if { $cache_product_as_file } {
        set active_product_list [db_list_of_lists get_all_active_product_ids "
      select product_id from ec_products
        where active_p='t' and present_p = 't'
        order by last_modified desc"]
        ns_log Notice "ecds_create_product_site_urls: processing [llength $active_product_list] products."
        foreach product_id $active_product_list {
            set sku ""
            set brandname ""
            set brand_name ""
            set brandmodelnumber ""
            if { $calc_sku } {
                db_0or1row check_product_history_2 {select a.sku as sku,a.last_modified as last_modified, b.brandname as brandname, b.brandmodelnumber as brandmodelnumber from ec_products a, ec_custom_product_field_values b where a.product_id = b.product_id and a.product_id = :product_id }
                if { [info exists brandname] } {
                    db_0or1row get_normalized_brand_name_from_alt_spelling "select normalized as brand_name from ecds_alt_spelling_map where alt_spelling =:brandname and context='brand'"
                } else {
                    ns_log Warning "ecds_create_product_site_urls: brandname is blank for product_id $product_id"
                }
                if { [info exists brand_name] && [string length $brand_name] > 0 } {
                    set brandname $brand_name
                }
    #            ns_log Notice "ecds_create_product_site_urls: brandname $brandname brandmodelnumber $brandmodelnumber "
                set new_sku [ecds_sku_from_brand $brandname $brandmodelnumber]
                if { $new_sku ne $sku } {
                    db_dml update_sku_for_a_product {update ec_products set sku = :new_sku where product_id = :product_id }
                    ns_log Notice "ecds_create_product_site_urls: updating sku from $sku to ${new_sku} for product_id ${product_id}"
                }
            }
            ecds_product_path_from_id $product_id $sku $brandname $brandmodelnumber
        }
    }
    ns_log Notice "ecds_create_product_site_urls: ended"
}

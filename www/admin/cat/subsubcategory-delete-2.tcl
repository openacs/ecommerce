# /www/[ec_url_concat [ec_url] /admin]/cat/subsubcategory-delete-2.tcl

ad_page_contract { 

    Deletes ecommerce product subsubcategory.

    @param subsubcategory_id
    @param subcategory_id
    @param subcategory_name
    @param category_id
    @param category_name

    @cvs-id subsubcategory-delete-2.tcl,v 3.1.6.5 2000/08/18 21:46:54 stevenp Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    subsubcategory_id:integer,notnull
    subcategory_id:integer,notnull
    subcategory_name:notnull
    category_id:integer,notnull
    category_name:notnull
}

ad_require_permission [ad_conn package_id] admin

# we need them to be logged in
set user_id [ad_verify_and_get_user_id]

if {$user_id == 0} {
    
    set return_url "[ad_conn url]?[export_url_vars category_name category_id subcategory_id subcategory_name subsubcategory_id]"

    ad_returnredirect "/register?[export_url_vars return_url]"
    return
}

# What has to be done (in order, so that no constraints are violated):
# 1. remove the rows in ec_subsubcategory_product_map where subsubcategory_id
# is $subsubcategory_id
# 2. remove the row in ec_subsubcategories where subsubcategory_id = $subsubcategory_id

# So, here goes:


db_transaction {

# 1. remove the rows in ec_subsubcategory_product_map where subsubcategory_id
# is $subsubcategory_id

db_dml delete_subsub_map "delete from ec_subsubcategory_product_map where subsubcategory_id=:subsubcategory_id"

# audit table
ec_audit_delete_row [list $subsubcategory_id] [list subsubcategory_id] ec_subsubcat_prod_map_audit

# 2. remove the row in ec_subsubcategories where subsubcategory_id = $subsubcategory_id

db_dml delete_subsubcats "delete from ec_subsubcategories where subsubcategory_id = :subsubcategory_id"

# audit table
ec_audit_delete_row [list $subsubcategory_id] [list subsubcategory_id] ec_subsubcategories_audit

}
db_release_unused_handles

ad_returnredirect "subcategory?[export_url_vars subcategory_id subcategory_name category_id category_name]"

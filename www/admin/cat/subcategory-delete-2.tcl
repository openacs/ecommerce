# /www/[ec_url_concat [ec_url] /admin]/cat/subcategory-delete-2.tcl
ad_page_contract {

    Deletes an ecommerce product subcategory.

    @param subcategory_id the ID of the subcategory
    @cvs-id $Id$
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    subcategory_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

# we need them to be logged in
set user_id [ad_conn user_id]

if {$user_id == 0} {
    
    set return_url "[ad_conn url]?[export_url_vars subcategory_id]"

    ad_returnredirect "/register?[export_url_vars return_url]"
    ad_script_abort
}

# What has to be done (in order, so that no constraints are violated):
# 1. remove the rows in ec_subsubcategory_product_map where the subsubcategory_ids
# share a row with $subcategory_id in ec_subsubcategories
# 2. remove those rows in ec_subsubcategories
# 3. remove the rows in ec_subcategory_product_map where the subcategory_id is
# $subcategory_id
# 4. remove the row in ec_subcategories where subcategory_id = $subcategory_id

# So, here goes:


db_transaction {

    # 1. remove the rows in ec_subsubcategory_product_map where the subsubcategory_ids
    # share a row with $subcategory_id in ec_subsubcategories

    set subsubcategory_list [db_list get_subsublist "select subsubcategory_id from ec_subsubcategories where subcategory_id=:subcategory_id"]

    db_dml delete_from_subsubmap "delete from ec_subsubcategory_product_map 
    where subsubcategory_id in (select subsubcategory_id from ec_subsubcategories where subcategory_id=:subcategory_id)"

    # audit table
    foreach subsubcategory $subsubcategory_list {
	ec_audit_delete_row [list $subsubcategory] [list subsubcategory_id] ec_subsubcat_prod_map_audit
    }

    # 2. remove those rows in ec_subsubcategories

    db_dml delete_from_ecsubsub "delete from ec_subsubcategories where subcategory_id=:subcategory_id"

    # audit table
    foreach subsubcategory $subsubcategory_list {
	ec_audit_delete_row [list $subsubcategory] [list subsubcategory_id] ec_subsubcategories_audit
    }

    # 3. remove the rows in ec_subcategory_product_map where the subcategory_id is
    # $subcategory_id

    db_dml delete_from_ec_sub_map "delete from ec_subcategory_product_map where subcategory_id=:subcategory_id"

    # audit table
    ec_audit_delete_row [list $subcategory_id] [list subcategory_id] ec_subcat_prod_map_audit

    # 4. remove the row in ec_subcategories where subcategory_id = $subcategory_id

    db_dml delete_from_ec_subcats "delete from ec_subcategories where subcategory_id=:subcategory_id"

    # audit table
    ec_audit_delete_row [list $subcategory_id] [list subcategory_id] ec_subcategories_audit

}

ad_returnredirect "index"

# /www/[ec_url_concat [ec_url] /admin]/cat/category-delete-2.tcl
ad_page_contract {

  Deletes ecommerce product category.

  @param  category_id the ID of the category to delete
  @cvs-id category-delete-2.tcl,v 3.1.6.7 2000/08/18 21:46:53 stevenp Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)

} {

    category_id:integer,notnull

}

ad_require_permission [ad_conn package_id] admin

# we need them to be logged in
set user_id [ad_verify_and_get_user_id]

if {$user_id == 0} {
    
    set return_url "[ad_conn url]?[export_url_vars category_name category_id subcategory_id]"

    ad_returnredirect "/register?[export_url_vars return_url]"
    return
}

# What has to be done (in order, so that no constraints are violated):
# 1. remove the rows in ec_subsubcategory_product_map where the 
# subsubcategory_ids share a row with the subcategory_ids that share a
# row with $category_id in ec_subcategories
# 2. remove those rows in ec_subsubcategories
# 3. remove the rows in ec_subcategory_product_map where the subcategory_ids
# share a row with $category_id in ec_subcategories
# 4. remove those rows in ec_subcategories
# 5. remove the rows in ec_category_product_map where the category_id is
# $category_id
# 6. remove the rows in ec_category_template_map where the category_id is
# $category_id
# 7. remove the row in ec_categories where category_id = $category_id

# So, here goes:


db_transaction {

# 1. remove the rows in ec_subsubcategory_product_map where the 
# subsubcategory_ids share a row with the subcategory_ids that share a
# row with $category_id in ec_subcategories

set subsubcategory_list [db_list get_subcategory_list "select subsubcategory_id from ec_subsubcategories where subcategory_id in (select subcategory_id from ec_subcategories where category_id=:category_id)"]

set subcategory_list [db_list get_subcategory_list_2 "select subcategory_id from ec_subcategories where category_id=:category_id"]

db_dml delete_ec_subcat_map "delete from ec_subsubcategory_product_map 
where subsubcategory_id in (select subsubcategory_id from ec_subsubcategories where subcategory_id in (select subcategory_id from ec_subcategories where category_id=:category_id))"

# audit table
foreach subsubcategory $subsubcategory_list {
    ec_audit_delete_row [list $subsubcategory] [list subsubcategory_id] ec_subsubcat_prod_map_audit
}

# 2. remove those rows in ec_subsubcategories

db_dml delete_ec_subcats "delete from ec_subsubcategories where subcategory_id in (select subcategory_id from ec_subcategories where category_id=:category_id)"

# audit table
foreach subsubcategory $subsubcategory_list {
    ec_audit_delete_row [list $subsubcategory] [list subsubcategory_id] ec_subsubcategories_audit
}

# 3. remove the rows in ec_subcategory_product_map where the subcategory_ids
# share a row with $category_id in ec_subcategories

db_dml delete_ec_subcat_map_1 "delete from ec_subcategory_product_map
where subcategory_id in (select subcategory_id from ec_subcategories where category_id=:category_id)"

# audit table
foreach subcategory $subcategory_list {
    ec_audit_delete_row [list $subcategory] [list subcategory_id] ec_subcat_prod_map_audit
}

# 4. remove those rows in ec_subcategories

db_dml delete_ec_subcats "delete from ec_subcategories where category_id=:category_id"

foreach subcategory $subcategory_list {
    ec_audit_delete_row [list $subcategory] [list subcategory_id] ec_subcategories_audit
}

# 5. remove the rows in ec_category_product_map where the category_id is
# $category_id

db_dml delete_ec_cat_prodmap "delete from ec_category_product_map where category_id=:category_id"
ec_audit_delete_row [list $category_id] [list category_id] ec_category_product_map_audit

# 6. remove the rows in ec_category_template_map where the category_id is
# $category_id

db_dml delete_ec_cat_templates "delete from ec_category_template_map where category_id=:category_id"

## no audit table associated with this one

db_dml delete_from_session_info "delete from ec_user_session_info where category_id=:category_id"


# 7. remove the row in ec_categories where category_id = $category_id

db_dml delete_ec_categories "delete from ec_categories where category_id=:category_id"
ec_audit_delete_row [list $category_id] [list category_id] ec_categories_audit

}
db_release_unused_handles

ad_returnredirect "index"







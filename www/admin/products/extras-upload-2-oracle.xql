<?xml version="1.0"?>

<queryset>
  <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

  <fullquery name="product_update_with_product_id">      
    <querytext>
      update ec_custom_product_field_values
        set last_modified=sysdate, last_modifying_user=:user_id, modified_ip_address=:ip $moresql
        where product_id = :var_$product_id_column
    </querytext>
  </fullquery>

  <fullquery name="product_update_with_sku">      
    <querytext>
      update ec_custom_product_field_values
        set last_modified=sysdate, last_modifying_user=:user_id, modified_ip_address=:ip $moresql
        where product_id = (select product_id from ec_products where sku = :var_$sku_column)"
    </querytext>
  </fullquery>
  
</queryset>

<?xml version="1.0"?>

<queryset>
  <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

  <fullquery name="product_update_with_product_id">      
    <querytext>
      update ec_custom_product_field_values
        set last_modified=sysdate, last_modifying_user=:user_id, modified_ip_address=:ip $moresql
        where product_id = :product_id
    </querytext>
  </fullquery>

  <fullquery name="product_insert_custom_fields_with_product_id">      
    <querytext>
    insert into ec_custom_product_field_values (last_modified, last_modifying_user, modified_ip_address, product_id
       ${moresqlinsert_columns} )
values (sysdate, :user_id, :ip, :product_id $moresqlinsert_values )
    </querytext>
  </fullquery>
  
</queryset>

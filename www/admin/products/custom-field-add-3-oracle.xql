<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>oracle</type>
    <version>8.1.6</version>
  </rdbms>

  <fullquery name="custom_field_insert">
    <querytext>
      insert into ec_custom_product_fields
      (field_identifier, field_name, default_value, column_type, last_modified, last_modifying_user, modified_ip_address)
      values
      (:field_identifier, :field_name, :default_value, :column_type, sysdate, :user_id, :peeraddr)
    </querytext>
  </fullquery>

  <fullquery name="alter_ec_custom_field_values_table">   
    <querytext>
      alter table ec_custom_product_field_values add (
      $field_identifier $column_type $end_of_alter)
    </querytext>
  </fullquery>

  <fullquery name="alter_ec_custom_field_values_audit_table">
    <querytext>
      alter table ec_custom_p_field_values_audit add (
      $field_identifier $column_type)
    </querytext>
  </fullquery>

  <fullquery name="custom_field_drop">
    <querytext>
      alter table ec_custom_product_field_values 
      drop column $field_identifier
    </querytext>
  </fullquery>
  
</queryset>

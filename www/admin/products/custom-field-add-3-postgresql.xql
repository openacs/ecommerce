<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>postgresql</type>
    <version>7.1</version>
  </rdbms>

  <fullquery name="custom_field_insert">
    <querytext>
      insert into ec_custom_product_fields
      (field_identifier, field_name, default_value, column_type, last_modified, last_modifying_user, modified_ip_address)
      values
      (:field_identifier, :field_name, :default_value, :column_type, current_timestamp, :user_id, :peeraddr)
    </querytext>
  </fullquery>

  <fullquery name="alter_ec_custom_field_values_table">   
    <querytext>
      alter table ec_custom_product_field_values 
      add column $field_identifier $column_type $end_of_alter
    </querytext>
  </fullquery>

  <fullquery name="alter_ec_custom_field_values_audit_table">
    <querytext>
      alter table ec_custom_p_field_values_audit 
      add column $field_identifier $column_type
    </querytext>
  </fullquery>

  <fullquery name="custom_field_drop">
    <querytext>
      -- PostgreSQL 7.1.3 can't drop columns and will fail on this query --
      alter table ec_custom_product_field_values 
      drop column $field_identifier
    </querytext>
  </fullquery>

  <fullquery name="drop_trigger_function">
    <querytext>
      drop function ec_custom_p_f_values_audit_tr ()
    </querytext>
  </fullquery>

  <fullquery name="drop_trigger">
    <querytext>
      drop trigger ec_custom_p_f_values_audit_tr on ec_custom_product_field_values
    </querytext>
  </fullquery>

  <fullquery name="create_trigger">
    <querytext>
      create trigger ec_custom_p_f_values_audit_tr
      before update or delete on ec_custom_product_field_values
      for each row execute procedure ec_custom_p_f_values_audit_tr ()
    </querytext>
  </fullquery>

</queryset>

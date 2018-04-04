<?xml version="1.0"?>
<queryset>

  <fullquery name="alter_table_drop">
    <querytext>
      -- PostgreSQL 7.1.2 will fail on this query as it doesn't support dropping of constraints --
      alter table ec_custom_product_field_values 
      drop constraint ${field_identifier}_constraint
    </querytext>
  </fullquery>

  <fullquery name="alter_table_modify">
    <querytext>
      -- PostgreSQL 7.1.2 will fail on this query as it can't modify columns --
      alter table ec_custom_product_field_values
      modify ($field_identifier $column_type)
    </querytext>
  </fullquery>

  <fullquery name="alter_table_modify_audit">
    <querytext>
      -- PostgreSQL 7.1.2 will fail on this query as it can't modify columns --
      alter table ec_custom_p_field_values_audit
      modify ($field_identifier $column_type)
    </querytext>
  </fullquery>

</queryset>

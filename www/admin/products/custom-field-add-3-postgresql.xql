<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<partialquery name="audit_info_sql">      
      <querytext>
      current_timestamp, :user_id, :peeraddr
      </querytext>
</partialquery>


<fullquery name="alter_statement_sql">
      <querytext>
      alter table ec_custom_product_field_values add column
      $field_identifier $column_type $end_of_alter
      </querytext>
</fullquery>


<fullquery name="alter_statement_2_sql">
      <querytext>

      alter table ec_custom_p_field_values_audit add column
      $field_identifier $column_type

      </querytext>
</fullquery>


<fullquery name="alter_statement_2_sql">
      <querytext>

      alter table ec_custom_product_field_values drop column $field_identifier

      </querytext>
</fullquery>



</queryset>

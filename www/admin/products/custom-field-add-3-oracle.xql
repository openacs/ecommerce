<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<partialquery name="audit_info_sql">      
      <querytext>
      sysdate, :user_id, :peeraddr
      </querytext>
</partialquery>

<fullquery name="alter_statement_sql">   
      <querytext>

      alter table ec_custom_product_field_values add (
      $field_identifier $column_type $end_of_alter)

      </querytext>
</fullquery>


<fullquery name="alter_statement_2">
      <querytext>

      alter table ec_custom_p_field_values_audit add (
      $field_identifier $column_type)

      </querytext>
</fullquery>

<fullquery name="custom_field_drop">
      <querytext>

      alter table ec_custom_product_field_values drop column $field_identifier

      </querytext>
</fullquery>


 
</queryset>

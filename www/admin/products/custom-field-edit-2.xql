<?xml version="1.0"?>
<queryset>

<fullquery name="alter_table_drop">      
      <querytext>
      alter table ec_custom_product_field_values drop constraint ${field_identifier}_constraint
      </querytext>
</fullquery>

 
<fullquery name="alter_table_modify">      
      <querytext>
      
      alter table ec_custom_product_field_values
	modify ($field_identifier $column_type)
      </querytext>
</fullquery>

 
<fullquery name="alter_table_modify_audit">      
      <querytext>
      
      alter table ec_custom_p_field_values_audit
	modify ($field_identifier $column_type)
      </querytext>
</fullquery>

 
</queryset>

<?xml version="1.0"?>
<queryset>

<fullquery name="dupliciate_field_identifier_select">      
      <querytext>
      select count(*) from ec_custom_product_fields where field_identifier=:field_identifier
      </querytext>
</fullquery>

 
<fullquery name="ec_products_column_conflict_select">      
      <querytext>
      select count(*) from user_tab_columns where column_name=upper(:field_identifier) and table_name='EC_PRODUCTS'
      </querytext>
</fullquery>

 
</queryset>

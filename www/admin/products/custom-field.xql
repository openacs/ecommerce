<?xml version="1.0"?>
<queryset>

<fullquery name="custom_field_select">      
      <querytext>
      
select field_name, default_value, column_type, active_p
from ec_custom_product_fields
where field_identifier=:field_identifier

      </querytext>
</fullquery>

 
</queryset>

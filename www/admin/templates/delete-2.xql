<?xml version="1.0"?>
<queryset>

<fullquery name="get_default_template">      
      <querytext>
      select default_template
from ec_admin_settings
      </querytext>
</fullquery>

 
<fullquery name="delete_from_ec_template_map">      
      <querytext>
      delete from ec_category_template_map where template_id=:template_id
      </querytext>
</fullquery>

 
<fullquery name="delete_from_ec_templates">      
      <querytext>
      delete from ec_templates where template_id=:template_id
      </querytext>
</fullquery>

 
</queryset>

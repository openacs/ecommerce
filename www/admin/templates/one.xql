<?xml version="1.0"?>
<queryset>

<fullquery name="">      
      <querytext>
      select template_name, template from ec_templates where template_id=:template_id
      </querytext>
</fullquery>

 
<fullquery name="get_default_template">      
      <querytext>
      select default_template from ec_admin_settings
      </querytext>
</fullquery>

 
</queryset>

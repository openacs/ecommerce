<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="insert_new_template">      
      <querytext>
      insert into ec_templates
(template_id, template_name, template, last_modified, last_modifying_user, modified_ip_address)
values
(:template_id, :template_name, :template, current_timestamp, :user_id, '[DoubleApos [ns_conn peeraddr]]')
      </querytext>
</fullquery>

 
</queryset>

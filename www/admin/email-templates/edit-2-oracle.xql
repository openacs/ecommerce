<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="update_ec_email_template">      
      <querytext>
      
     update ec_email_templates
     set title=:title, 
         subject=:subject, 
         message=:message, 
         variables=:variables, 
         when_sent=:when_sent, 
         issue_type_list=:issue_type, 
         last_modified=sysdate, 
         last_modifying_user=:user_id, 
         modified_ip_address='[DoubleApos [ns_conn peeraddr]]'
     where email_template_id=:email_template_id
      </querytext>
</fullquery>

 
</queryset>

<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="unused">      
      <querytext>
      insert into ec_email_templates
(email_template_id, title, subject, message, variables, when_sent, issue_type_list, last_modified, last_modifying_user, modified_ip_address)
values
(ec_email_template_id_sequence.nextval, :title, :subject, :message, :variables, :when_sent, :issue_type, current_timestamp, :user_id, '[DoubleApos [ns_conn peeraddr]]')
      </querytext>
</fullquery>

 
</queryset>

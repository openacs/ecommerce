<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="ec_audit_process_row.audit_table_insert">      
      <querytext>
      
    insert into $audit_table_name
           ($id_column_join last_modified,
           last_modifying_user, modified_ip_address, delete_p)
    values ($id_column_bind_join current_timestamp,
            :last_modifying_user, :modified_ip_address, :delete_p)
    
      </querytext>
</fullquery>

 
</queryset>

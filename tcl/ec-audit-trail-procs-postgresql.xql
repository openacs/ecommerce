<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>postgresql</type>
    <version>7.1</version>
  </rdbms>

  <fullquery name="ec_audit_delete_row.audit_table_insert">      
    <querytext>
      insert into $audit_table_name
      ($id_column_join last_modified, last_modifying_user, modified_ip_address, delete_p)
      values 
      ($id_column_bind_join current_timestamp, :last_modifying_user, :modified_ip_address, :delete_p)
    </querytext>
  </fullquery>

  <fullquery name="ec_audit_trail.get_entries_sql">
    <querytext>
      select $audit_table_name.*, $audit_table_name.oid as rowid, to_char($audit_table_name.last_modified, 'Mon DD, YYYY HH12:MI AM') as last_modified, 
      	  users.first_names || ' ' || users.last_name as modifying_user_name
      from $audit_table_name, cc_users users
      where users.user_id = $audit_table_name.last_modifying_user $audit_table_id_clause $date_clause
      order by $audit_table_name.last_modified asc
    </querytext>
  </fullquery>
  
</queryset>

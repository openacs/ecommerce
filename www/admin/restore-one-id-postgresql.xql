<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="get_audit_rows">      
      <querytext>
      select * from $audit_table_name where oid as rowid = :rowid
      </querytext>
</fullquery>

 
</queryset>

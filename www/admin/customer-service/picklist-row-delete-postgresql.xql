<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="telere_from_picklist_table">      
      <querytext>
      delete from $table_name where oid as rowid=:rowid
      </querytext>
</fullquery>

 
</queryset>

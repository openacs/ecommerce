<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>oracle</type>
    <version>8.1.6</version>
  </rdbms>

  <fullquery name="get_audit_rows">      
    <querytext>
      select * 
      from $audit_table_name
      where rowid = :rowid
    </querytext>
  </fullquery>

</queryset>

<?xml version="1.0"?>

<queryset>

  <fullquery name="ec_audit_process_row.audit_table_column_select">      
    <querytext>
      select distinct $id_column
      from $main_table_name
      where [join $date_clause_list "\nand "]
    </querytext>
  </fullquery>

  <fullquery name="ec_audit_process_row.audit_table_column_select">      
    <querytext>
      select distinct $id_column
      from $main_table_name
      where [join $date_clause_list "\nand "]
    </querytext>
  </fullquery>

</queryset>

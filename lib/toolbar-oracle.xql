<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>oracle</type>
    <version>8.1.6</version>
  </rdbms>

  <fullquery name="get_check_of_categories">      
    <querytext>
      select 1 
      from dual 
      where exists (select 1 
          from ec_categories)
    </querytext>
  </fullquery>

</queryset>

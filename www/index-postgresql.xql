<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>postgresql</type>
    <version>7.1</version>
  </rdbms>

  <fullquery name="get_check_of_categories">      
    <querytext>
      select 1  where exists (select 1 
          from ec_categories)
    </querytext>
  </fullquery>

</queryset>

<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="get_exipre_from_Db">      
      <querytext>
      select [ec_decode $expires "" "null" $expires] from dual
      </querytext>
</fullquery>

 
</queryset>

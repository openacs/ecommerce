<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="get_exipre_from_Db">      
      <querytext>
      select [ec_decode $expires "" "null" $expires] 
      </querytext>
</fullquery>

 
</queryset>

<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="select_one">      
      <querytext>
      select 1  where to_date('$sale_begins(date)','YYYY-MM-DD HH24:MI:SS')  >to_date('$sale_ends(date)', 'YYYY-MM-DD HH24:MI:SS')
      </querytext>
</fullquery>

 
<fullquery name="sale_price_id_select">      
      <querytext>
      select ec_sale_price_id_sequence.nextval 
      </querytext>
</fullquery>

 
</queryset>

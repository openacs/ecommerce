<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="get_new_ship_seq">      
      <querytext>
      select ec_shipment_id_sequence.nextval from dual
      </querytext>
</fullquery>

 
</queryset>

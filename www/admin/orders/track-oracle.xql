<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="shipment_select">      
      <querytext>
      
select to_char(shipment_date, 'MMDDYY') as ship_date_for_fedex, to_char(shipment_date, 'MM/DD/YYYY') as pretty_ship_date, carrier, tracking_number
from ec_shipments
where shipment_id = :shipment_id

      </querytext>
</fullquery>

 
</queryset>

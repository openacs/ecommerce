<?xml version="1.0"?>
<queryset>

<fullquery name="duplicate_offer_select">      
      <querytext>
      
select count(*) from ec_offers
where product_id=:product_id
and retailer_id=:retailer_id
and deleted_p='f'
and (($to_date_offer_begins >= offer_begins and $to_date_offer_begins <= offer_ends) or ($to_date_offer_ends >= offer_begins and $to_date_offer_ends <= offer_ends) or ($to_date_offer_begins <= offer_ends and $to_date_offer_ends >= offer_ends))

      </querytext>
</fullquery>

 
<fullquery name="retailer_name_select">      
      <querytext>

select retailer_name || ' (' || case when reach = 'web' then url else city || ', ' || usps_abbrev end || ')'  from ec_retailers where retailer_id=:retailer_id

      </querytext>
</fullquery>

 
</queryset>

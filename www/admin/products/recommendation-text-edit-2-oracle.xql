<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="recommendation_text_update">      
      <querytext>
      
update ec_product_recommendations 
set recommendation_text = :recommendation_text,
    last_modified=sysdate,
    last_modifying_user=:user_id,
    modified_ip_address=:peeraddr
where recommendation_id=:recommendation_id

      </querytext>
</fullquery>

 
</queryset>

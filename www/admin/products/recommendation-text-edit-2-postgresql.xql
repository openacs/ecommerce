<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="recommendation_text_update">      
      <querytext>
      
update ec_product_recommendations 
set recommendation_text = :recommendation_text,
    last_modified=current_timestamp,
    last_modifying_user=:user_id,
    modified_ip_address=:peeraddr
where recommendation_id=:recommendation_id

      </querytext>
</fullquery>

 
</queryset>

<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="product_review_update">      
      <querytext>
      
update ec_product_reviews
set product_id=:product_id,
    publication=:publication,
    author_name=:author_name,
    review_date=[ec_datetime_sql review_date],
    review=:review,
    display_p=:display_p,
    last_modified=current_timestamp,
    last_modifying_user=:user_id,
    modified_ip_address=:peeraddr
where review_id=:review_id

      </querytext>
</fullquery>

 
</queryset>

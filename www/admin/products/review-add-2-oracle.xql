<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="review_insert">      
      <querytext>
      insert into ec_product_reviews
(review_id, product_id, publication, author_name, review, display_p, review_date, last_modified, last_modifying_user, modified_ip_address)
values
(:review_id, :product_id, :publication, :author_name, :review, :display_p, to_date(:review_date, 'YYYY-MM-DD HH24:MI:SS'), sysdate, :user_id, :peeraddr)

      </querytext>
</fullquery>

 
</queryset>

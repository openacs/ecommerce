<?xml version="1.0"?>

<queryset>

  <fullquery name="ecommerce_user_contributions.get_addresses">      
    <querytext>
      select address_id
      from ec_addresses where user_id = :user_id
    </querytext>
  </fullquery>
  
  <fullquery name="ecommerce_user_contributions.get_product_reviews_for_user">      
    <querytext>
      select c.comment_id, p.product_name, comment_date
      from ec_product_comments c, ec_products p
      where c.product_id = p.product_id
      and user_id = :user_id
    </querytext>
  </fullquery>
  
</queryset>

<?xml version="1.0"?>

<queryset>

  <fullquery name="product_name_and_double_click_check">      
    <querytext>
      select product_name,
      comment_found_p
      from  ec_products,
      (select count(*) as comment_found_p
          from  ec_product_comments
          where comment_id = :comment_id) ec_comments_count
          where product_id = :product_id
    </querytext>
  </fullquery>

</queryset>

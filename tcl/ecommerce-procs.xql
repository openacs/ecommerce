<?xml version="1.0"?>

<queryset>

  <fullquery name="ec_id_mem.acs_ec_id_get">      
    <querytext>
      select package_id from apm_packages
      where package_key = 'ecommerce'
    </querytext>
  </fullquery>
  
  <fullquery name="ec_category_subcategory_and_subsubcategory_display.subcategories_select">      
    <querytext>
      select subcategory_id 
      from ec_subcategories 
      where category_id = :category_id 
      and subcategory_id in ([join $subcategory_list ", "]) 
      order by subcategory_name
    </querytext>
  </fullquery>

  <fullquery name="ec_category_subcategory_and_subsubcategory_display.category_name_select_1">      
    <querytext>
      select category_name 
      from ec_categories 
      where category_id = :category_id
    </querytext>
  </fullquery>

  <fullquery name="ec_category_subcategory_and_subsubcategory_display.category_name_select_2">      
    <querytext>
      select category_name 
      from ec_categories 
      where category_id = :category_id
    </querytext>
  </fullquery>

  <fullquery name="ec_category_subcategory_and_subsubcategory_display.subcategory_name_select_1">      
    <querytext>
      select subcategory_name 
      from ec_subcategories 
      where subcategory_id = :subcategory_id
    </querytext>
  </fullquery>

  <fullquery name="ec_category_subcategory_and_subsubcategory_display.subcategory_name_select_2">      
    <querytext>
      select subsubcategory_name 
      from ec_subsubcategories 
      where subcategory_id = :subcategory_id 
      and subsubcategory_id in ([join $subsubcategory_list ","]) 
      order by subsubcategory_name
    </querytext>
  </fullquery>

  <fullquery name="ec_product_name_internal.product_name_select">      
    <querytext>
      select product_name 
      from ec_products 
      where product_id = :product_id and present_p = 't'
    </querytext>
  </fullquery>

  <fullquery name="ec_full_categorization_display.subcategory_id_select">      
    <querytext>
      select subcategory_id 
      from ec_subsubcategories 
      where subsubcategory_id = :subsubcategory_id
    </querytext>
  </fullquery>

  <fullquery name="ec_full_categorization_display.category_id_select">      
    <querytext>
      select category_id 
      from ec_subcategories 
      where subcategory_id = :subcategory_id
    </querytext>
  </fullquery>

  <fullquery name="ec_full_categorization_display.category_name_select">      
    <querytext>
      select category_name
      from ec_categories
      where category_id = :category_id
    </querytext>
  </fullquery>

  <fullquery name="ec_full_categorization_display.subcategory_name_select">      
    <querytext>
      select subcategory_name
      from ec_subcategories
      where subcategory_id = :subcategory_id
    </querytext>
  </fullquery>

  <fullquery name="ec_full_categorization_display.subsubcategory_name_select">      
    <querytext>
      select subsubcategory_name
      from ec_subsubcategories 
      where subsubcategory_id = :subsubcategory_id
    </querytext>
  </fullquery>

  <fullquery name="ec_full_categorization_display.category_id_select">      
    <querytext>
      select category_id
      from ec_subcategories
      where subcategory_id = :subcategory_id
    </querytext>
  </fullquery>

  <fullquery name="ec_full_categorization_display.category_name_select">      
    <querytext>
      select category_name
      from ec_categories 
      where category_id = :category_id
    </querytext>
  </fullquery>

  <fullquery name="ec_full_categorization_display.subcategory_name_select">      
    <querytext>
      select subcategory_name
      from ec_subcategories 
      where subcategory_id = :subcategory_id
    </querytext>
  </fullquery>

  <fullquery name="ec_full_categorization_display.category_name_select">      
    <querytext>
      select category_name
      from ec_categories 
      where category_id = :category_id
    </querytext>
  </fullquery>

  <fullquery name="ec_full_categorization_display.category_id_select">      
    <querytext>
      select category_id
      from ec_category_product_map
      where product_id = :product_id
    </querytext>
  </fullquery>

  <fullquery name="ec_full_categorization_display.subcategory_id_select">      
    <querytext>
      select s.subcategory_id
      from ec_subcategory_product_map m, ec_subcategories s
      where m.subcategory_id = s.subcategory_id
      and s.category_id = :category_id
      and m.product_id = :product_id
    </querytext>
  </fullquery>

  <partialquery name="ec_mailing_list_link_for_a_product.mailing_categories_common">
    <querytext>
      (select cpm.category_id, bla.subcategory_id, cpm.product_id
               from ec_category_product_map cpm 
               left join (select sc.category_id, spm.subcategory_id, spm.product_id
                          from ec_subcategory_product_map spm, ec_subcategories sc 
                          where sc.subcategory_id = spm.subcategory_id) as bla 
               using (category_id, product_id)
      		   where cpm.product_id = :product_id
               ) as bogus 
              left join (select sc.category_id, ssc.subcategory_id, sspm.subsubcategory_id, sspm.product_id
                         from ec_subsubcategory_product_map sspm, ec_subcategories sc, ec_subsubcategories ssc 
                         where sspm.subsubcategory_id = ssc.subsubcategory_id 
                         and ssc.subcategory_id = sc.subcategory_id
                         ) as boring 
              using (category_id, subcategory_id, product_id)
    </querytext>
  </partialquery>

  <fullquery name="ec_product_links_if_they_exist.product_link_info_select">      
    <querytext>
      select p.product_id, p.product_name
      from ec_products_displayable p, ec_product_links l
      where l.product_a = :product_id
      and l.product_b = p.product_id
    </querytext>
  </fullquery>

  <fullquery name="ec_professional_reviews_if_they_exist.professional_reviews_info_select">      
    <querytext>
      select publication, author_name, review_date, review 
      from ec_product_reviews 
      where product_id = :product_id
      and display_p = 't'
    </querytext>
  </fullquery>

  <fullquery name="ec_customer_comments.avg_rating_select">      
    <querytext>
      select avg(rating) 
      from ec_product_comments
      where product_id = :product_id
      and approved_p = 't'
    </querytext>
  </fullquery>

  <fullquery name="ec_customer_comments.n_reviews_select">      
    <querytext>
      select count(*) 
      from ec_product_comments
      where product_id = :product_id
      and (approved_p='t' [ec_decode [util_memoize {ad_parameter -package_id [ec_id] ProductCommentsNeedApprovalP ecommerce} [ec_cache_refresh]] "0" "or approved_p is null" ""])
    </querytext>
  </fullquery>

  <fullquery name="ec_navbar.category_select">      
    <querytext>
      select category_id, category_name
      from ec_categories
      order by sort_key
    </querytext>
  </fullquery>

  <fullquery name="ec_order_summary_for_customer.correct_user_id">      
    <querytext>
      select user_id as correct_user_id
      from ec_orders 
      where order_id = :order_id
    </querytext>
  </fullquery>

  <fullquery name="ec_order_summary_for_customer.order_info_select">      
    <querytext>
      select o.confirmed_date, o.creditcard_id, o.shipping_method,
      u.email, o.shipping_address as shipping_address_id, c.billing_address as billing_address_id
      from ec_orders o
      left join cc_users u on (o.user_id = u.user_id)
      left join ec_creditcards c on (o.creditcard_id = c.creditcard_id)
      where o.order_id = :order_id
    </querytext>
  </fullquery>

  <fullquery name="ec_order_summary_for_customer.order_details_select">      
    <querytext>
      select i.price_name, i.price_charged, i.color_choice, i.size_choice, i.style_choice, p.product_name, p.one_line_description, p.product_id, p.sku, count(*) as quantity
      from ec_items i, ec_products p
      where i.order_id = :order_id
      and i.product_id = p.product_id
      group by p.product_name, p.one_line_description, p.product_id, p.sku, i.price_name, i.price_charged, i.color_choice, i.size_choice, i.style_choice
    </querytext>
  </fullquery>

  <fullquery name="ec_item_summary_in_confirmed_order.item_summary_info_select">      
    <querytext>
      select i.price_charged, i.price_name, i.color_choice, i.size_choice, i.style_choice, p.sku, p.product_name, p.one_line_description, p.product_id, count(*) as quantity
      from ec_items i, ec_products p
      where i.order_id = :order_id
      and i.product_id = p.product_id
      group by p.sku, p.product_name, p.one_line_description, p.product_id, i.price_charged, i.price_name, i.color_choice, i.size_choice, i.style_choice
    </querytext>
  </fullquery>

  <fullquery name="ec_item_summary_in_confirmed_order.item_summary_info_select">      
    <querytext>
      select i.price_charged, i.price_name, i.color_choice, i.size_choice, i.style_choice, p.product_name, p.one_line_description, p.product_id, count(*) as quantity
      from ec_items i, ec_products p
      where i.order_id = :order_id
      and i.product_id = p.product_id
      group by p.product_name, p.one_line_description, p.product_id,
      i.price_charged, i.price_name, i.color_choice, i.size_choice, i.style_choice
    </querytext>
  </fullquery>

  <fullquery name="ec_items_for_fulfillment_or_return.n_items_in_an_order_select">      
    <querytext>
      select count(*) 
      from $item_view 
      where order_id = :order_id
    </querytext>
  </fullquery>

  <fullquery name="ec_all_orders_by_one_user.all_orders_one_user_select">      
    <querytext>
      select o.order_id, o.confirmed_date, o.order_state
      from ec_orders o
      where o.user_id = :user_id
      order by o.order_id
    </querytext>
  </fullquery>

  <fullquery name="ec_display_product_purchase_combinations.get_pp_combs">      
    <querytext>
      select * 
      from ec_product_purchase_comb 
      where product_id = :product_id
    </querytext>
  </fullquery>

  <fullquery name="ec_product_name_internal.product_name_select">      
    <querytext>
      select product_name 
      from ec_products 
      where product_id = :product_id and present_p = 't'
    </querytext>
  </fullquery>

  <fullquery name="ec_shipment_summary_sub.items_shipped_select">      
    <querytext>
      select s.shipment_date, s.carrier, s.tracking_number, s.shipment_id, s.shippable_p, count(*) as n_items
      from ec_items i, ec_shipments s
      where i.order_id = :order_id
      and i.shipment_id = s.shipment_id
      and i.product_id = :product_id
      and i.color_choice [ec_decode $color_choice "" "is null" "= :color_choice"]
      and i.size_choice [ec_decode $size_choice "" "is null" "= :size_choice"]
      and i.style_choice [ec_decode $style_choice "" "is null" "= :style_choice"]
      and i.price_charged [ec_decode $price_charged "" "is null" "= :price_charged"]
      and i.price_name [ec_decode $price_name "" "is null" "= :price_name"]
      group by s.shipment_date, s.carrier, s.tracking_number, s.shipment_id, s.shippable_p
    </querytext>
  </fullquery>

  <fullquery name="ec_canned_response_selector.canned_response_select">      
    <querytext>
      select response_id, one_line, response_text
      from ec_canned_responses
      order by one_line
    </querytext>
  </fullquery>

  <fullquery name="ec_user_class_display.user_class_info_select">      
    <querytext>
      select c.user_class_name, m.user_class_approved_p, c.user_class_id
      from ec_user_classes c, ec_user_class_user_map m
      where m.user_id = :user_id
      and m.user_class_id = c.user_class_id
      order by c.user_class_id
    </querytext>
  </fullquery>

  <fullquery name="ec_log_user_as_user_id_for_this_session.user_session_update">      
    <querytext>
      update ec_user_sessions 
      set user_id = :user_id 
      where user_session_id = :user_session_id
    </querytext>
  </fullquery>

  <fullquery name="ec_state_name_from_usps_abbrev.state_name_from_usps_abbrev">      
    <querytext>
      select state_name 
      from us_states 
      where abbrev = :usps_abbrev
    </querytext>
  </fullquery>

  <fullquery name="ec_country_name_from_country_code.country_name_from_country_code">      
    <querytext>
      select default_name 
      from countries 
      where iso = :country_code
    </querytext>
  </fullquery>
  
</queryset>

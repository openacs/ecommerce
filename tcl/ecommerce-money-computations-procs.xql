<?xml version="1.0"?>
<queryset>

<fullquery name="ec_lowest_price_and_price_name_for_an_item.get_price">      
      <querytext>
      select price from ec_products where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="ec_lowest_price_and_price_name_for_an_item.get_product_infos">      
      <querytext>
      
        select p.price, c.user_class_name
        from ec_product_user_class_prices p, ec_user_classes c
        where p.product_id=:product_id
        and p.user_class_id=c.user_class_id
        and p.user_class_id in (select m.user_class_id from ec_user_class_user_map m where m.user_id=:user_id $additional_user_class_restriction)
    
      </querytext>
</fullquery>

 
<fullquery name="ec_lowest_price_and_price_name_for_an_item.get_sale_prices">      
      <querytext>
      select sale_price, sale_name
    from ec_sale_prices_current
    where product_id=:product_id
    and (offer_code is null $or_part_of_query)
    
      </querytext>
</fullquery>

 
<fullquery name="ec_shipping_price_for_one_item.get_shipping_info">      
      <querytext>
      select shipping, shipping_additional, weight from ec_products where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="ec_shipping_price_for_one_item.get_default_shipping_info">      
      <querytext>
      select default_shipping_per_item, weight_shipping_cost from ec_admin_settings
      </querytext>
</fullquery>

 
<fullquery name="ec_shipping_price_for_one_item.get_first_item">      
      <querytext>
      select min(item_id) from ec_items where product_id=:product_id and order_id:order_id
      </querytext>
</fullquery>

 
<fullquery name="ec_shipping_price_for_one_item.get_exp_info">      
      <querytext>
      select add_exp_amount_per_item, add_exp_amount_by_weight from ec_admin_settings
      </querytext>
</fullquery>

 
<fullquery name="ec_price_price_name_shipping_price_tax_shipping_tax_for_one_item.get_item_price">      
      <querytext>
      select price from ec_products where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="ec_price_price_name_shipping_price_tax_shipping_tax_for_one_item.get_price_and_name">      
      <querytext>
      select p.price, c.user_class_name
	from ec_product_user_class_prices p, ec_user_classes c
	where p.product_id=:product_id
	and p.user_class_id=c.user_class_id
	and p.user_class_id in ([join $user_class_id_list ", "])
      </querytext>
</fullquery>

 
<fullquery name="ec_lowest_price_and_price_name_for_an_item.get_sale_prices">      
      <querytext>
      select sale_price, sale_name
    from ec_sale_prices_current
    where product_id=:product_id
    and (offer_code is null $or_part_of_query)
    
      </querytext>
</fullquery>

 
<fullquery name="ec_price_price_name_shipping_price_tax_shipping_tax_for_one_item.get_shipping_costs">      
      <querytext>
      select shipping, shipping_additional, weight from ec_products where product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="ec_price_price_name_shipping_price_tax_shipping_tax_for_one_item.get_first_instance">      
      <querytext>
      select min(item_id) from ec_items where product_id=:product_id and order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="ec_price_shipping_gift_certificate_and_tax_in_an_order.get_confirmed_info">      
      <querytext>
      
	select confirmed_date, user_id,
	       ec_total_price(:order_id) as total_price,
	       ec_total_shipping(:order_id) as total_shipping,
	       ec_total_tax(:order_id) as total_tax
	from ec_orders
	where order_id = :order_id
    
      </querytext>
</fullquery>

 
</queryset>

<?xml version="1.0"?>
<queryset>

<fullquery name="num_non_void_items_select">      
      <querytext>
      select count(*) from ec_items where order_id=:order_id and product_id=:product_id and item_state <> 'void'
      </querytext>
</fullquery>

 
<fullquery name="num_items_select">      
      <querytext>
      select count(*) from ec_items where order_id=:order_id and product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="item_state_select">      
      <querytext>
      select item_state from ec_items where order_id=:order_id and product_id=:product_id
      </querytext>
</fullquery>

 
<fullquery name="num_shipped_items_select">      
      <querytext>
      select count(*) from ec_items where order_id=:order_id and product_id=:product_id and item_state in ('shipped','arrived','received_back')
      </querytext>
</fullquery>

 
<fullquery name="order_products_select">      
      <querytext>
      select i.item_id, i.item_state, p.product_name, i.price_name, i.price_charged
    from ec_items i, ec_products p
    where i.product_id=p.product_id
    and i.order_id=:order_id
    and i.product_id=:product_id
      </querytext>
</fullquery>

 
</queryset>

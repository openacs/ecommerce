<?xml version="1.0"?>
<queryset>

<fullquery name="doublclick_select">      
      <querytext>
      select count(*) from ec_items where item_id=:item_id
      </querytext>
</fullquery>

 
<fullquery name="creditcard_id_select">      
      <querytext>
      select creditcard_id from ec_orders where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="shipping_method_select">      
      <querytext>
      select shipping_method from ec_orders where order_id=:order_id
      </querytext>
</fullquery>

 
<fullquery name="ec_items_update">      
      <querytext>
      update ec_items set shipping_charged=:shipping_price where item_id=:item_id
      </querytext>
</fullquery>

 
</queryset>

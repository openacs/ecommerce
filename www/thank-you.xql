<?xml version="1.0"?>

<queryset>

  <fullquery name="get_order_id_info">      
    <querytext>
      select order_id 
      from ec_orders
      where user_id=:user_id and confirmed_date is not null
      and order_id=(select max(o2.order_id) 
      	  from ec_orders o2
	  where o2.user_id=$user_id 
          and o2.confirmed_date is not null)
    </querytext>
  </fullquery>

</queryset>

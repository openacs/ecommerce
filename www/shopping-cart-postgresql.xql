<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>postgresql</type>
    <version>7.1</version>
  </rdbms>

  <fullquery name="check_for_saved_carts">      
    <querytext>
      select 1  where exists (select 1 
	  from ec_orders 
          where user_id=:user_id 
          and order_state = 'in_basket' 
          and saved_p='t')
    </querytext>
  </fullquery>

</queryset>

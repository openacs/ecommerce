<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="user_id_sql">
      <querytext>

      select distinct o.user_id, u.first_names, u.last_name, u.email
      from ec_orders o, cc_users u
      where o.user_id=u.user_id
      and o.order_state not in ('void','in_basket')
      and current_timestamp - o.confirmed_date <= timespan_days(:days)
      and :amount <= (select sum(i.price_charged) from ec_items i where i.order_id=o.order_id and (i.item_state is null or i.item_state not in ('void','received_back')))

      </querytext>
</fullquery>

 
</queryset>

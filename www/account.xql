<?xml version="1.0"?>
<queryset>

<fullquery name="get_orders">      
      <querytext>
      select order_id, confirmed_date from ec_orders
where user_id=:user_id
and order_state not in ('in_basket','void','expired')
order by order_id
      </querytext>
</fullquery>

 
<fullquery name="get_gift_certificates">      
      <querytext>
      select 
gift_certificate_id, issue_date, amount
from ec_gift_certificates
where purchased_by=:user_id
and gift_certificate_state in ('authorized','authorized_plus_avs','authorized_minus_avs', 'confirmed')
      </querytext>
</fullquery>

 
<fullquery name="get_mailing_lists">      
      <querytext>

select 
 ml.category_id, 
 c.category_name,
 ml.subcategory_id, 
 s.subcategory_name, 
 ml.subsubcategory_id,
 ss.subsubcategory_name
from ec_cat_mailing_lists ml
 LEFT JOIN ec_categories c using(category_id)
 LEFT JOIN ec_subcategories s using (subcategory_id)
 LEFT JOIN ec_subsubcategories ss on (ml.subsubcategory_id = ss.subsubcategory_id)
where ml.user_id = :user_id

      </querytext>
</fullquery>

 
</queryset>

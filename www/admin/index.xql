<?xml version="1.0"?>
<queryset>

<fullquery name="unresolved_problem_count_select">      
      <querytext>
      select count(*) from ec_problems_log where resolved_date is null
      </querytext>
</fullquery>

 
<fullquery name="num_orders_select">      
      <querytext>
      
select 
  sum(one_if_within_n_days(confirmed_date,1)) as n_in_last_24_hours,
  sum(one_if_within_n_days(confirmed_date,7)) as n_in_last_7_days
from ec_orders_reportable
      </querytext>
</fullquery>

 
<fullquery name="num_products_select">      
      <querytext>
      select count(*) as n_products, round(avg(price),2) as avg_price from ec_products_displayable
      </querytext>
</fullquery>

 
<fullquery name="open_issues_select">      
      <querytext>
      select count(*) from ec_customer_service_issues where close_date is null
      </querytext>
</fullquery>

 
<fullquery name="non_approved_comments_select">      
      <querytext>
      select count(*) from ec_product_comments where approved_p is null
      </querytext>
</fullquery>

 
<fullquery name="non_approved_users_select">      
      <querytext>
      select count(*) from ec_user_class_user_map where user_class_approved_p is null or user_class_approved_p='f'
      </querytext>
</fullquery>

 
</queryset>

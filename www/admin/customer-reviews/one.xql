<?xml version="1.0"?>
<queryset>

<fullquery name="get_product_info">      
      <querytext>
      select c.product_id, c.user_id, c.user_comment, c.one_line_summary, c.rating, p.product_name, u.email, c.comment_date, c.approved_p
from ec_product_comments c, ec_products p, cc_users u
where c.product_id = p.product_id
and c. user_id = u.user_id 
and c.comment_id=:comment_id
      </querytext>
</fullquery>

 
</queryset>

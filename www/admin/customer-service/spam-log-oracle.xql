<?xml version="1.0"?>

<queryset>
  <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

  <fullquery name="get_spam_people">      
    <querytext>
      select spam_text, mailing_list_category_id, mailing_list_subcategory_id, mailing_list_subsubcategory_id, user_class_id, product_id, to_char(last_visit_start_date,'YYYY-MM-DD HH24:MI:SS') as full_last_visit_start_date, to_char(last_visit_end_date,'YYYY-MM-DD HH24:MI:SS') as full_last_visit_end_date, to_char(spam_date,'YYYY-MM-DD HH24:MI:SS') as full_spam_date 
      from ec_spam_log 
      where (spam_date >= to_date('$start 00:00:00','YYYY-MM-DD HH24:MI:SS') and spam_date <= to_date('$end 23:59:59','YYYY-MM-DD HH24:MI:SS')) 
      order by spam_date desc
    </querytext>
  </fullquery>

</queryset>
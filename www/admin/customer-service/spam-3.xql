<?xml version="1.0"?>
<queryset>

<fullquery name="get_log_entries_cnt">      
      <querytext>
      select count(*) from ec_spam_log where spam_id=:spam_id
      </querytext>
</fullquery>

 
<fullquery name="insert_log_for_spam">      
      <querytext>
      
    insert into ec_spam_log
        (spam_id, spam_text, mailing_list_category_id, 
         mailing_list_subcategory_id, mailing_list_subsubcategory_id, 
         user_class_id, product_id, 
         last_visit_start_date, last_visit_end_date)
    values
        (:spam_id, :message, :mailing_list_category_id, 
         :mailing_list_subcategory_id, :mailing_list_subsubcategory_id, 
         :user_class_id, :product_id, 
         to_date(:start_date,'YYYY-MM-DD HH24:MI:SS'), 
         to_date(:end_date,'YYYY-MM-DD HH24:MI:SS'))
    
      </querytext>
</fullquery>

 
</queryset>

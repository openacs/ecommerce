<?xml version="1.0"?>
<queryset>

<fullquery name="delete_from_mailing_lists">      
      <querytext>
      delete from ec_cat_mailing_lists where user_id=:user_id and subsubcategory_id=:subsubcategory_id
      </querytext>
</fullquery>

 
<fullquery name="delete_from_mailing_lists_2">      
      <querytext>
      delete from ec_cat_mailing_lists where user_id=:user_id and subcategory_id=:subcategory_id and subsubcategory_id is null
      </querytext>
</fullquery>

 
<fullquery name="delete_just_from_category">      
      <querytext>
      delete from ec_cat_mailing_lists where user_id=:user_id and category_id is null
      </querytext>
</fullquery>

 
</queryset>

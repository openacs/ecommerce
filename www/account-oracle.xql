<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>oracle</type>
    <version>8.1.6</version>
  </rdbms>

  <fullquery name="get_gift_certificate_balance">      
    <querytext>
      select ec_gift_certificate_balance(:user_id) 
      from dual
    </querytext>
  </fullquery>

  <fullquery name="get_user_view_classes">      
    <querytext>
      select 1 
      from dual where exists (select 1 
          from ec_user_classes)
    </querytext>
  </fullquery>

  <fullquery name="get_mailing_lists">      
    <querytext>
      select ml.category_id, c.category_name, ml.subcategory_id, s.subcategory_name, ml.subsubcategory_id, ss.subsubcategory_name
      from ec_cat_mailing_lists ml, ec_categories c, ec_subcategories s, ec_subsubcategories ss
      where ml.user_id = :user_id
      and ml.category_id = c.category_id(+)
      and ml.subcategory_id = s.subcategory_id(+)
      and ml.subsubcategory_id = ss.subsubcategory_id(+)
    </querytext>
  </fullquery>

</queryset>

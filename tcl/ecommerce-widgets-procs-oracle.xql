<?xml version="1.0"?>

<queryset>

  <rdbms>
    <type>oracle</type>
    <version>8.1.6</version>
  </rdbms>

  <partialquery name="ec_gift_certificate_expires_widget.now">
    <querytext>
      sysdate
    </querytext>
  </partialquery>

  <fullquery name="ec_date_widget.date_widget_select">      
    <querytext>
      select to_char(sysdate, 'YYYY-MM-DD') from dual
    </querytext>
  </fullquery>
  
  <fullquery name="ec_time_widget.time_widget_select">      
    <querytext>
      select to_char(sysdate, 'HH24:MI:SS') from dual
    </querytext>
  </fullquery>

  <fullquery name="ec_category_widget.get_category_info_joined_w_children">
    <querytext>
      select c.category_id, c.category_name,
      s.subcategory_id, s.subcategory_name,
      ss.subsubcategory_id, ss.subsubcategory_name
      from ec_categories c, ec_subcategories s, ec_subsubcategories ss
      where c.category_id = s.category_id (+)
      and s.subcategory_id = ss.subcategory_id (+)
      order by c.sort_key, s.sort_key, ss.sort_key
    </querytext>
  </fullquery>

  <fullquery name="ec_mailing_list_widget.get_category_children">
    <querytext>
      select c.category_id, c.category_name, s.subcategory_id, s.subcategory_name, ss.subsubcategory_id, ss.subsubcategory_name
      from ec_categories c, ec_subcategories s, ec_subsubcategories ss, ec_cat_mailing_lists m
      where m.category_id=c.category_id(+)
      and m.subcategory_id=s.subcategory_id(+)
      and m.subsubcategory_id=ss.subsubcategory_id(+)
      order by decode(c.category_id, null, 0, c.sort_key), decode(s.subcategory_id, null, 0, s.sort_key), decode(ss.subcategory_id, null, 0, ss.sort_key)
    </querytext>
  </fullquery>
  
</queryset>

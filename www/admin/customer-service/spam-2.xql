<?xml version="1.0"?>
<queryset>

  <partialquery name="mailing_list">
    <querytext>
      select user_id, first_names, last_name from cc_users where user_id in ([join $user_id_list ", "])
    </querytext>
  </partialquery>

  <partialquery name="null_categories">
    <querytext>
      (category_id is null and subcategory_id is null and subsubcategory_id is null)
    </querytext>
  </partialquery>

  <partialquery name="null_subcategory">
    <querytext>
      (category_id=:mailing_list and subcategory_id is null)
    </querytext>
  </partialquery>

  <partialquery name="null_subsubcategory">
    <querytext>
      (subcategory_id=[lindex $mailing_list 1] and subsubcategory_id is null)
    </querytext>
  </partialquery>

  <partialquery name="subsubcategory">
    <querytext>
      subsubcategory_id=[lindex $mailing_list 2]
    </querytext>
  </partialquery>

  <partialquery name="null_categories">
    <querytext>
      select users.user_id, first_names, last_name from cc_users, ec_cat_mailing_lists where users.user_id=ec_cat_mailing_lists.user_id
    </querytext>
  </partialquery>

  <partialquery name="user_class">
    <querytext>
      select u.user_id, first_names, last_name from cc_users u, ec_user_class_user_map m where m.user_class_id=:user_class_id and m.user_id=u.user_id
    </querytext>
  </partialquery>

  <partialquery name="all_users">
    <querytext>
      select user_id, first_names, last_name from cc_users
    </querytext>
  </partialquery>

  <partialquery name="last_visit">
    <querytext>
      select user_id, first_names, last_name from cc_users where last_visit >= to_date(:start,'YYYY-MM-DD HH24:MI:SS') and last_visit <= to_date(:end,'YYYY-MM-DD HH24:MI:SS')
    </querytext>
  </partialquery>

</queryset>

<?xml version="1.0"?>
<queryset>

  <fullquery name="delete_from_issue_type_map">      
    <querytext>
      delete from ec_cs_issue_type_map where issue_id=:issue_id
    </querytext>
  </fullquery>
  
  <fullquery name="insert_into_type_map">      
    <querytext>
      insert into ec_cs_issue_type_map (issue_id, issue_type) values (:issue_id,:issue_type)
    </querytext>
  </fullquery>
  
</queryset>

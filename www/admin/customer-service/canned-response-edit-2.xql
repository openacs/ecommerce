<?xml version="1.0"?>
<queryset>

<fullquery name="update_cs_canned_response">      
      <querytext>
      update ec_canned_responses
set one_line = :one_line, response_text = :response_text
where response_id = :response_id
      </querytext>
</fullquery>

 
</queryset>

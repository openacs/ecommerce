<?xml version="1.0"?>
<queryset>

<fullquery name="get_response_id">      
      <querytext>
      select response_id from ec_canned_responses where one_line = :one_line
      </querytext>
</fullquery>

 
<fullquery name="insert_new_canned_response">      
      <querytext>
      insert into ec_canned_responses (response_id, one_line, response_text)
values (ec_canned_response_id_sequence.nextval, :one_line, :response_text)
      </querytext>
</fullquery>

 
</queryset>

<?xml version="1.0"?>
<queryset>

<fullquery name="get_response_info">      
      <querytext>
      select one_line, response_text
from ec_canned_responses
where response_id = :response_id
      </querytext>
</fullquery>

 
</queryset>

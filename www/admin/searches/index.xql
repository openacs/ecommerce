<?xml version="1.0"?>
<queryset>

  <fullquery name="search_summary">      
    <querytext>
	SELECT count(search_text) as num_searches, search_text 
	FROM ec_user_session_info 
	WHERE search_text is not null and length(trim(search_text)) > 0
	GROUP BY search_text 
	ORDER BY count(search_text) desc;
    </querytext>
  </fullquery>
  
  
</queryset>

<?xml version="1.0"?>
<queryset>

<fullquery name="ec_style_user_preferences_from_db.preference_select">      
      <querytext>
      
	select prefer_text_only_p, language_preference 
	from user_preferences 
	where user_id = :user_id
    
      </querytext>
</fullquery>

 
</queryset>

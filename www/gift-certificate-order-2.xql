<?xml version="1.0"?>
<queryset>

<fullquery name="gco_email">      
      <querytext>
      
        select email
          from persons, parties
         where person_id = :mightbe
           and person_id = party_id
        
      </querytext>
</fullquery>

 
</queryset>

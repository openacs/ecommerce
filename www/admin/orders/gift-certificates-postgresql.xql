<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<partialquery name="last_24">
      <querytext>
      and now()-g.issue_date <= timespan_days(1)
      </querytext>
</partialquery>


<partialquery name="last_week">
      <querytext>
      and now()-g.issue_date <= timespan_days(7)
      </querytext>
</partialquery>


<partialquery name="last_month">
      <querytext>
      and now()-g.issue_date <= '1 month'::interval
      </querytext>
</partialquery>


</queryset>

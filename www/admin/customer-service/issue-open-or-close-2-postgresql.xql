<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="update_service_issue">      
      <querytext>
      update ec_customer_service_issues set close_date=current_timestamp, closed_by=:customer_service_rep where issue_id=:issue_id
      </querytext>
</fullquery>

 
</queryset>

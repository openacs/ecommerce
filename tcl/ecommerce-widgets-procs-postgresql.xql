<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="ec_creditcard_widget.date_widget_select">      
      <querytext>
      select to_char(current_timestamp, 'YYYY-MM-DD') 
      </querytext>
</fullquery>

 
<fullquery name="ec_creditcard_widget.time_widget_select">      
      <querytext>
      select to_char(current_timestamp, 'HH24:MI:SS') 
      </querytext>
</fullquery>

 
</queryset>

<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="ec_creditcard_widget.date_widget_select">      
      <querytext>
      select to_char(sysdate, 'YYYY-MM-DD') from dual
      </querytext>
</fullquery>

 
<fullquery name="ec_creditcard_widget.time_widget_select">      
      <querytext>
      select to_char(sysdate, 'HH24:MI:SS') from dual
      </querytext>
</fullquery>

 
</queryset>

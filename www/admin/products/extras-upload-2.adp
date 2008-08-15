<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

@doc_body;noquote@
 
<if @serious_errors@ false>
<p>Done reading @count_html@ rows from @csv_file@, updated(.) @rows_updated@ and inserted(i) @rows_inserted@ product extras!
</p>
<p>
(Note: "success" doesn't actually mean that the information was uploaded; it
just means that the database did not choke on it (since updates to tables are considered
successes even if 0 rows are updated).  If you need reassurance, spot check some of the individual products.)
</p>

</if>

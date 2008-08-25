<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<h3>Your Current Settings</h3>
<if @taxes_counter@ eq 0>
  <p>No tax is currently charged in any state.</p
</if><else>
  <ul>
    @sales_taxes_html;noquote@
  </ul>
</else>

<h3>Change Your Settings</h3>
<p>Please select all the states in which you need to charge sales tax.  You will be asked
later what the tax rates are and whether to charge tax on shipping in those states.
</p>
<form method=post action=edit>
@state_widget_html;noquote@
<center>
  <input type=submit value="Submit">
</center>
</form>

<h3>Clear All Settings</h3>
<p>
If you want to start from scratch, <a href="clear">clear all settings</a>.
</p>
<p>In general, you must collect sales tax on orders shipped to states
where you have some kind of physical presence, e.g., a warehouse, a
sales office, or a retail store.  
</p><p>
Some sources of data on sales tax rates by zip codes are: 
</p>
<ul>
<li><a href="http://www.salestax.com">www.salestax.com</a> - their Sales Tax Assistant - All States, Single User was $1,650 as of
3/8/2004.</li>
<li><a href="http://zip2tax.com/info.html">Zip2Tax.com</a> - $490 for US and protectorates.</li>
<li><a
href="http://www.taxadmin.org/fta/rate/sales.html">www.taxadmin.org</a> 
- State tax tables from the Federation of Tax Administrators (free).</li>
<li><a href="ksrevenue.org/5digitzip.htm">KSrevenue.org</a>
 - Kansas dept of revenue's 5-digit Zip Code TaxRate Info.</li>
<li><a href="http://en.wikipedia.org/wiki/Sales_taxes_in_the_United_States">http://en.wikipedia.org/wiki/Sales_taxes_in_the_United_States</a>
- Sales taxes and related info at Wikipedia, with references to state
publications that provide more detail.</li>
</ul>
<p>
We tried to keep this module simple by ignoring the ugly fact of local
taxing jurisdictions (e.g., that New York City collects tax on top of
what New York State collects).  If you're a Fortune 500 company with
nexus in 50 states, you'll probably have to add in a fair amount of
complexity to collect tax more precisely or at least <em>remit</em>
sales tax more precisely.  
</p>
<h3>Audit Trail</h3>
<ul>
<li><a href="@audit_url_html;noquote">Audit Sales Tax Settings</a>
</ul>

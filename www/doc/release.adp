<master src=master>
<property name=title>Ecommerce Release Notes</property>

<h2>E-commerce Package Version 4.1a (first Alpha release)</h2></h2>

<h3>Features</h3>
<p>The goal of this release was to bring the ACS 3x ecommerce module'
s features to an ACS 4x package.  You can find a feature summary in the <a href="ecommerce-features">Features of the Ecommerce Module</a> document.

<p>Keep in mind that this release isn't a redesign of E-commerce to take advantage of all of ACS 4x new features.  It doesn't have multiple retailer handling, nor can package be mounted in multiple instances in the site-map and work correctly.  Templating is still done with the old E-commerce templating system (although it now lives alongside ATS).  I hope that these improvements can be rolled into a future release.  For now, those whose needs are satisfied by the functionality of the old ecommerce module, but want to move to ACS 4x, should be happy.  To everybody who wants something more, we would love your contributions of code!  Please see the <a href="http://openacs.org/sdm/">OpenACS SDM</a> to report bugs (patches always welcome) or make feature requests.

<p>For more details about the porting process check out this partial <a href="porting-diary">porting diary</a>.

<h3>Requirements</h3>
<ul>
<li><a href="http://arsdigita.com/acs-repository/">ACS 4.1.1</a> (developed on 4.1.1, may work with later versions)</li>
<li><a href="http://furfly.net/downloads">ACS Geotables</a></li>
<li>Optional: <a href="http://arsdigita.com/acs-repository/">Site Wide Search Package (4.0.1)</a> and all its dependencies if you want to incorporate products into Site Wide Search
</ul>

<h3>Known Issues</h3>

<p>As this is an alpha release there are a few things that still need to be fixed.

<ul> 
<li>www/admin/products/upload-2.tcl needs to be converted to using the PL/SQL function ec_product.new instead of old insert.</li>
<li>A number of auditing inserts are not working.</a>
<li>The included (but disabled by default) CyberCash emulator has some problems, see the <a href="ecommerce-technical">Technical documentation</a> for details.
<li>The optional Site Wide Search interface results in the following error when a trying to rebuild the index after a new ec_product object has been created (ECOM_4X_DEV was the oracle user name):
<p>
<blockquote>
<code><pre>
ERR_INDEX_NAME		       ERR_TIMEST ERR_TEXTKEY
------------------------------ ---------- ------------------
ERR_TEXT
--------------------------------------------------------------------------------
SWS_SRCH_CTS_DS_IIDX	       2001-04-06 AAAGkQAAIAAAEh5AAD
DRG-12604: execution of user datastore procedure has failed
DRG-50857: oracle error in drsinopen
ORA-06550: line 1, column 18:
PLS-00302: component 'SWS_INDEX_PROC' must be declared
ORA-06550: line 1, column 7:
PL/SQL: Statement ignored
ORA-06512: at "ECOM_4X_DEV.SWS_SERVICE", line 230
ORA-06512: at "ECOM_4X_DEV.SWS_SERVICE", line 260

</pre></code>
</blockquote>
I'm pretty sure that the bug is actually in the SWS code, not the E-commerce package.
<p>
<li><a href="ecommerce-technical">Technical documentation</a> is still a little rough.  You should be able to get things working with the documentation as is.  It doesn't cover how to find, download, and install a package.  I suspect all that is needed here is a link to an adequate document, but I haven't had a chance to find it yet.  If you have questions please email <a href="mailto:wtem@olywa.net">wtem@olywa.net</a>.
</ul>
We welcome any bugs fixes for any of these problems, please contact <a href="mailto:wtem@olywa.net">wtem@olywa.net</a> if you come up with fixes and/or visit 
the <a href="http://openacs.org/sdm/">OpenACS SDM</a></ul> 


<h3>Functions "removed" from acs 4 stuck back into ec</h3>
<blockquote>
    <table>
      <tr><th>was</th><th>is</th></tr>
      <tr><td>util_GetUserAgentHeader</td><td>ecGetUserAgentHeader</td></tr>
      <tr><td>ad_register_styletag</td><td>ec_register_styletag</td></tr>
      <tr><td>ad_style_template_root_internal</td><td>ec_style_template_root_internal</td></tr>
      <tr><td>ad_style_template_root</td><td>ec_style_template_root</td></tr>
      <tr><td>ad_style_language_from_cookie</td><td>ec_style_language_from_cookie</td></tr>
      <tr><td>ad_style_plain_fancy_from_cookie</td><td>ec_style_plain_fancy_from_cookie</td></tr>
      <tr><td>ad_style_user_preferences_from_db</td><td>ec_style_user_preferences_from_db</td></tr>
      <tr><td>ad_style_score_templates</td><td>ec_style_score_templates</td></tr>
      <tr><td>ad_style_sort_by_score</td><td>ec_style_sort_by_score</td></tr>
      <tr><td>ad_return_template</td><td>ec_return_template</td></tr>
      <tr><td>cc_send_to_server_21</td><td>cc_send_to_server_21</td></tr>
      <tr><td>qmail</td><td>qmail</td></tr>
      <tr><td>qmail_send_complete_message</td><td>qmail_send_complete_message</td></tr>
      <tr><td>logical_negation</td><td>logical_negation</td></tr>
      <tr><td>one_if_within_n_days</td><td>one_if_within_n_days</td></tr>
      <tr><td>pseudo_contains</td><td>pseudo_contains</td></tr>
      <tr><td>util_decode</td><td>util_decode</td></tr>
      <tr><td>ad_audit_trail</td><td> ec_audit_trail</td></tr>
      <tr><td>ad_audit_trail_for_table</td><td> ec_audit_trail_for_table</td></tr>
      <tr><td>ad_state_name_from_usps_abbrev</td><td>ec_state_name_from_usps_abbrev</td></tr>
      <tr><td>ad_country_name_from_country_code</td><td>ec_country_name_from_country_code</td></tr>
      <tr><td>fm_adp_function_p</td><td>ec_adp_function_p</td></tr>
      <tr><td>util_IllustraDatetoPrettyDate</td><td>ec_IllustraDatetoPrettyDate</td></tr>
    </table>
</blockquote>

</ul>

</td></tr></table>
</blockquote>

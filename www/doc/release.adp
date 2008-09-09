<master>
  <property name=title>@title;noquote@</property>
  <property name="signatory">@signatory;noquote@</property>
  <property name="context_bar">@context_bar;noquote@</property>
    
  <h2>Features</h2>

  <p>This release brings the ACS 5.1 ecommerce
    module' s features to OpenACS 5.4+.  You can find a feature
    summary in the <a href="ecommerce-features">Features of the
    Ecommerce Module</a> document.

    <p>This is a singleton package, meaning it can be mounted only
    once in the site-map.</p>
  
  <h2>Requirements</h2>

  <ul>
    <li><a href="http://openacs.org/xowiki/docs-eng/">OpenACS 5.4</a>
    or above.</li>
	

  </ul>

  <h2>Known Issues</h2>

  <p>As this is an alpha release there are a few things that still
    need to be fixed.</p>

  <ul> 
    <li>The Site Wide Search for ecommerce has not be integrated with
	the search facilities available for OpenACS 5.3+.  
    The optional Site Wide Search interface has not changed from 5.1,
    where tests result in the
      following error when a trying to rebuild the index after a new
      ec_product object has been created (ECOM_4X_DEV was the oracle
      user name):
      <blockquote>
	<code>
	<pre>
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
	</pre>
      </code>
      </blockquote>

    <li>In addition to <a href="ecommerce-technical">Technical
      documentation</a>, refer to <a
      href="http://openacs.org/xowiki/docs-admin-help">Getting
      admin-level help</a> for ways to get personalized help.</li>

  </ul>

  <p>Enhancements and bug fixes are welcome.</p>


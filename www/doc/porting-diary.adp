<master>
  <property name=title>@title;noquote@</property>
  <property name="signatory">@signatory;noquote@</property>
  <property name="context_bar">@context_bar;noquote@</property>

  <h2>Diary</h2>
  
  <ul>

    <li>
      <p>Initial import into 4.0.  Collected files from acs-3.4.8 doc,
	doc/sql, tcl, admin/ecommerce, and ecommerce/ (and later from
	templates).  Moved ad.ini params into ecommerce params.</p>
    </li>

    <li>
      <p>ec_create_new_session_if_necessary (ecommerce-defs.tcl),
	redirects to the cookie chain were removed (as cookie chain
	strategy has been altered radically in 4.0 (removing the
	cookie-chain code.)</p>

      <p><a
        href="http://www.arsdigita.com/bboard/q-and-a-fetch-msg?msg_id=0003Dn">a
        new standard?</a></p>

      <blockquote>

	<p>Our standard in the future is going to be that we always
	  redirect the user to "www.sitename.com" if they try to
	  access the site as "sitename.com". Then we can set cookies
	  with Domain=.sitename.com and they will take effect on all
	  cobranded sites.  A better answer is not to use cookies at
	  all (directly)! The new session-tracking facilities (see the
	  security and session-tracking documentation) take care of
	  managing session or persistent state for you in the
	  database, securely if necessary.</p>

	<p>-- Jon Salz, April 13, 2000 </p>

      </blockquote>
    </li>

    <li>
      <p>ad.ini params moved into ecommerce/styles package params.</p>
    </li>

    <li>
      <p>Modified calls to ad_parameter to take into account
	package_id using [ec_id].  Ironically, this may take port a
	step backward and prevent it from being mounted more than once
	in a site.  This can be relaxed by changing ec_id to find the
	"right" ecommerce package as opposed to the first one, (or
	whichever one it is finding.)</p>
    </li>

    <li>
      <p>Wrapped ad_parameter calls with util_memoize -- I think the
	4.0 ad_parameter is cool but quick benchmarking shows it is
	potentially very slow.  The util_memoize call uses the value
	of ec_cache_refresh to periodically refresh the cache.  (This
	should be simplified and built into ad_parameter if you ask
	me.)</p>
    </li>

    <li>
      <p>Checked for nsssl and made ecommerce compatible with
	nsopenssl.</p>
    </li>

    <li>
      <p>Checked for nsunix and made ecommerce compatible with
	nsunix.</p>
    </li>

    <li>
      <p>Added ecommerce-security-procs to help make it easy to create
	links to and from secure pages.  (Used code "repurposed" from
	David Rodriguez's ACS 3.4 events modules and enhanced for
	nsopenssl and nsunix compatibility.</p>
    </li>

    <li>
      <p>Added kernel security parameter SecureLoginsRequiredP, which
	defaults to 1.  For most ecommerce sites, this should probably
	be set to 0 by the site admin.  The affect of this parameter
	is to lessen security somewhat, but to keep users from having
	to login twice, once for an http and once for an https
	session.</p>
    </li>

    <li>
      <p>Later modified security_processor's sec_handler, as well as login
	pages in acs-subsite...register to emulate Amazon's behavior.  When
	login on https is requested, email address of non-secure http user is
	presented.</p>

      <p>More information can be found at <a
	href="http://www.arsdigita.com/sdm/one-ticket?ticket_id=9767">ACS
	feature request 9767</a></p>
    </li>

    <li>
      <p>tags-search-replace "/ecommerce/" "[ec_url]"</p>
    </li>

    <li>
      <p>replaced calls to philg_email_valid_p with ad_page_contract
	... email filter (in gift-certificates....)</p>
    </li>

    <li>
      <p>changed references to table users_preferences to
	user_preferences.</p>
    </li>

    <li>
      <p>changed references to table users to table cc_users</p>
    </li>

    <li>
      <p>changed pages that made their own secure/insecure links to use
      ec_securelink (which securelink will fallback to an insecure link if
      that is all that is available.)</p>
    </li>

    <li>
      <p>copied qmail.tcl from acs-3.4.8 to ecommerce/tcl/qmail-procs.tcl.
	Eventually, ecommerce should instead use the ACS 4.1 acs-mail system.</p>
    </li>

    <li>
      <p>incorporated gift certificate fix from <a
	href="http://www.arsdigita.com/bboard/q-and-a-fetch-msg?msg_id=000YLy&topic_id=21&topic=web%2fdb">aD
	forum</a></p>
    </li>

    <li>
      <p>got product search working, I needed to copy
	acs-3.4.8/www/doc/sql/pl-sql.sql to
	ecommerce/sql/pl-sql-utilities-create.sql. Also created a
	-drop script.  Deleted functions and procs not used by
	ecommerce.</p>
    </li>

    <li>
      <p>changed view ec_customer_service_reps to use cc_users and not
	users, checked that there were no other bad references to
	users in ecommerce-create.sql</p>
    </li>

    <li>
      <p>started rationalizing outgoing email messages: blew through
	code (tags search) to ensure everyone gets the from address
	correctly (using the [ec ..] routine) so that
	ec_sendmail_from_service can put something better than just
	"Customer Service" on the from header.</p>
    </li>

    <li>
      <p>in templates that send gift certs out change the link to
	include ecommerce mount point to get back to the store
	itself.</p>
    </li>

    <li>
      <p>fix bug in admin/shipping-costs/edit involving validation of
	shipping charges (shipping weight)</p>
    </li>

    <li>
      <p>imported ad_audit_trail facilities</p>
    </li>

    <li>
      <p>fixed up nav bars and ec footers to point to
	"\[ec_system_name\] Home" and not just Home as sites might
	have multiple ecommerce packages mounted and to indicate that
	ecommerce home is not the same as site home</p>
    </li>

    <li>
      <p>fixed up https links once more pointing to site home page</p>
    </li>

    <li>
      <p>fixed up register/index and request processor so that a login
	page redirect by transition from http to https contains the
	email address of the user.</p>
    </li>

    <li>
      <p>tags search replace of context_bar.*ecommerce to
	.. Ecommerce(\[ec_system_name\])</p>
    </li>

    <li>
      <p>tags search, add ad_require_permission admin to all admin
	pages</p>
    </li>

    <li>
      <p>fix up ec_navbar to offer admins an admin link</p>
    </li>

    <li>
      <p>parameterized ImageMagick's convert utility (since it might
	not live in /usr/local/bin).  Created an ecommerce package
	parameter, appropriately memoized getter function.  Placed
	getter in admin/products/add-2 and edit-2.</p>
    </li>

    <li>
      <p>checked for existence of convert utility (as more elegant
	than just catching failure)</p>
    </li>

    <li>
      <p>checked for failure of convert utility as it runs</p>
    </li>

    <li>
      <p>fixed url generation of images, given new structure of acs
	packages (not just under AOLservers webroot, but under package
	webroot)</p>
    </li>

    <li>
      <p>removed registered proc that handles /product-file requests and
	converts them to real names, created product-file/index.vuh to return
	correct file</p>
    </li>

    <li>
      <p>generalized a product's one line and detailed description so
	it could contain html, which it appears it used to but now
	cannot since ad_page_contract, defaults to using the filter
	:nohtml.  How many more of these are there?  Does it need to
	be :allhtml?</p>
    </li>

    <li>
      <p>fixed a bug in ec_display_rating
	s/EcommerceDirectory/EcommerceDataDirectory/</p>
    </li>

    <li>
      <p>tweaked product template in ecommerce-create.sql to display
	ec_navbar (and to make category_id available to template)</p>
    </li>

    <li>
      <p>fixed up hardcoded www/admin to lookup url of acs-admin
	package to fix up links to /acs-admin/users/one</p>
    </li>

    <li>
      <p>fixed up doc so that /admin/ecommerce is usually
	/ecommerce/admin or [ec_url]admin</p>
    </li>

    <li>
      <p>replaced philg_quote_double_quotes with ad_quotehtml</p>
    </li>

    <li>
      <p>replaced philg_hidden_imput with ec_hidden_input</p>
    </li>

    <li>
      <p>Fixed ecommerce-create.sql to include country-code and state
	fields that Janine commented out.</p>
    </li>

    <li>
      <p>Tuned checkout pipeline, ensuring that it's https if possible
	the entire time, that users are logged in, that there are no
	links out of pipeline (not a requirement, just a "selling"
	focus) until final page, that the navbar changes to show the
	various steps in the checkout pipeline ala amazon, and that on
	final page, links away are insecure and direct the visitor
	back to http mode.</p>
    </li>

    <li>
      <p>moved ad_adp_function_p to ec_adp_function_p, mainly used in
	taking submission of templates from admins but restricting
	them to template without tcl functions, and made the behavior
	subject to an ecommerce style paramter.  Changed the
	complaints to use ad_return_complaint.</p>
    </li>

    <li>
      <p>fixed bug in add member to mailing list which forgot (unlike
	acs3 user-search to add percents around pattern to wildcard:
	%pattern%</p>
    </li>

    <li>
      <p>fixed two bugs in items-add-(2 3).  In items-add-2, use
	ec_add_to_cart_link instead of ec_add_to_cart_link_sub.  In
	items-add-3, change sytle to style.  Did anyone ever
	user/report this?</p>
    </li>

    <li>
      <p>made sure that product directory can be outside webroot so that
	uploaded .tcl/.adp, etc. files cannot be executed with a webhit.</p>
    </li>
      
    <li>
      <p>fix queries in customer-service/actions.tcl and
	statistics.tcl to use cc_users</p>
    </li>

    <li>
      <p>fix bug in email-send failing when there is no customer email
	address</p>
    </li>

    <li>
      <p>fix bug in admin/sales-tax/clear-2.tcl which called
	ec_audit_delete_row with a "wildcard" of "", something beyon
	the simple API of ec_audit_delete_row.</p>
    </li>

  </ul>

  <h3>Todo</h3>

  <ul>
    <li>
      <p>collect addresses of gift certificate people</p>
    </li>

    <li>
      <p>better utilize ad_page_contract contracts and filters</p>
    </li>

    <li>
      <p>did a tags query replace for <code>users</code> to
	<code>cc_users</code></p>
    </li>

    <li>
      <p>make gift certificate claim checks a link</p>
    </li>
    
    <li>
      <p>need to resolve the last modifying user during package
	creation time, setting it to user_id of initializer?</p>
    </li>

    <li>
      <p>add yourself to email link is annoying, it should not display
	if you are already subscribed</p>
    </li>

    <li>
      <p>should products be able to be in both a subcategory AND a
	category at the same time?  If yes, change
	admin/products/edit-2.tcl</p>
    </li>

    <li>
      <p>generalize search to search through all categories, or store,
	or site</p>
    </li>

    <li>
      <p>generalize product templates to be mapped to subcategories
	and subsubcategories.</p>
    </li>

    <li>
      <p>place all references to ad_parameters into an ec_parameters
	tcl file</p>
    </li>

    <li>
      <p>cleanup meaning of "no shipping" -- is this strictly for
	services (e.g. software development), downloadable products,
	etc. or does this reflect something else (e.g. hole in
	database initialization).  Perhaps parameterize display of "no
	shipping" so that sites can make that display as "services",
	or "downloads."</p>
    </li>

    <li>
      <p>add an inventory module</p>
    </li>

    <li>
      <p>add a top level link to
	admin/orders/fulfillment-items-needed</p>
    </li>

    <li>
      <p>add downloads of data in csv or excel form to get into
	spreadsheets</p>
    </li>

    <li>
      <p>create page (or module) specific doc and add links to those
	doc pages</p>
    </li>

    <li>
      <p>add top level page to view various logs, including
	ec_automatic_email_log, ec_spam_log</p>
    </li>

  </ul>

  <h3>To test (or to fix)</h3>

  <ul>
    <li>
      <p>fix back button back to a form in ssl mode (known to expire
	immediately)</p>
    </li>

    <li>
      <p>As usual aD module is meant to create, not maintain.  In this
	case, ec_sessions and ec_orders are created but never
	deleted</p>
    </li>

    <li>
      <p>replace ec_sessions with ad_sessions</p>
    </li>

    <li>
      <p><b>reengineer to prevent url hacking</b></p>
    </li>

    <li>
      <p>Order emails do not contain an order number or a tracking
	link</p>
    </li>

    <li>
      <p>Gift cert emails don't contain a link back to the site to
	automagically redeem the gift cert</p>
    </li>

    <li>
      <p>audit tables are often not working</p>
    </li>

    <li>
      <p>make user classes more interesting</p>
    </li>

    <li>
      <p>offer ability to add one, multiple, or all members from a search to class</p>
    </li>

    <li>
      <p>add some data mining (people who purchased in last n days,
	got refunds, bought more than x, bought ...</p>
    </li>

    <li>
      <p>parameterize the classes (bought more than X days, or bought
	more than Y)</p>
    </li>

    <li>
      <p>add complex searches to them bought more than AND bought from
	category</p>
    </li>

    <li>
      <p>add a QBE interface to search</p>
    </li>
    
    <li>
      <p>unify ec tables with acs object system, esp wrt. permissions
	and audit trails</p>
    </li>
  </ul>

  <h3>Add maintenance and exports tasks</h3>

  <ul>
    <li>
      <p>Archive/Purge:</p>
      <ul>
	<li>ec_automatic_email_log</li>
	<li>ec_problems_log</li>
	<li>ec_financial_transactions</li>
	<li>ec_customer_service_issues</li>
	<li>ec_spam_log</li>
      </ul>
    </li>
  </ul>

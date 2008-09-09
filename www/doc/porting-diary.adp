<master>
  <property name=title>@title;noquote@</property>
  <property name="signatory">@signatory;noquote@</property>
  <property name="context_bar">@context_bar;noquote@</property>

  <h3>Porting diary</h3>
    <p>Porting diary details are currently tracked via CVS browsers
  linked from <a href="http://openacs.org/">OpenACS.org</a>.</p>
  <h3>Todo</h3>

  <ul>
    <li>
      <p>collect addresses of gift certificate people</p>
    </li>

    <li>
      <p>better utilize ad_page_contract contracts and filters</p>
    </li>

    <li>
      <p>a tags query replace for <code>users</code> to
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
      <p>generalize product templates to be mapped to subcategories
	and subsubcategories.</p>
    </li>

    <li>
      <p>make ecommerce subsite aware</p>
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


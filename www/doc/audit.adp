<master>
  <property name=title>Audit Trail Package</property>
  <property name="signatory">@signatory@</property>

  <h2>@title@</h2>
  <table width="100%">
    <tbody>
      <tr>
	<td align="left">@context_bar@</td>
      </tr>
    </tbody>
  </table>
  <hr>

  <h2>The Big Picture</h2>

  <p>When you have more than one person updating information in a
    table, you want to record all the values of a row over time.  This
    package gives you (1) a standard way of naming tables and triggers
    in Oracle, (2) two Tcl procedures (<code>ec_audit_trail</code> and
    <code>ec_audit_trail_for_table</code>) that helps you display the
    old values of a row, including highlighting particular changed
    columns, (3) a Tcl procedure (<code>ec_audit_delete_row</code>)
    that simplifies the logging of a deleted row, and (4) an example
    user interface ( <code>audit-tables</code>,
    <code>audit-table</code>, <code>audit</code>) to retrieve and
    display audit histories.</p>

  <h2>Steps for Auditing a Table</h2>

  <p>We record old information in a separate audit table (see <a
      href="http://www.arsdigita.com/books/sql/triggers">the triggers
      chapter of <cite>SQL for Web Nerds</cite></a> for more
      explanation of this idea).</p>

  <p> We distinguish between the on-line transaction processing (OLTP)
    tables that are used in the minute-by-minute operation of the
    server and the audit tables.</p>

  <p>Here are the steps to add audit trails:</p>

  <ul>
    
    <li>
      <p>Decide which OLTP tables need auditing. Three fields must be
	added to each OLTP table to save information about who was
	making changes, what IP address they were using, and the date
	they made the changes.</p>

      <blockquote>
	<pre>
	  create table ec_products (
	  product_id              integer not null primary key,
	  product_name            varchar(200),
	  one_line_description    varchar(400),

	  ...

	  -- the user ID and IP address of the last modifier of the product
	  <font color=red>        last_modified           date not null,
	    last_modifying_user     not null references users,
	    modified_ip_address     varchar(20) not null</font>
	  );
	</pre>
      </blockquote>
    </li>

    <li>
      <p>Create one audit table for each OLTP table that is being
	audited.  By convention, this table should be named by adding
	an "_audit" suffix to the OLTP table name.  The audit table
	has all the columns of the main table, with the same data
	types but no integrity constraints.  Also add a flag to
	indicate that an audit entry is for a deleted row in the OLTP
	table.</p>

      <blockquote>
	<pre>
	  create table ec_products<font color=red>_audit</font> as
	  select * from ec_products where 1 = 0;

	  alter table ec_products<font color=red>_audit</font> add (
	  delete_p    char(1) default('f') check (delete_p in ('t','f'))
	  );
	</pre>
      </blockquote>
    </li>

    <li>
      <p>Add one update trigger for each OLTP table.</p>
      <blockquote>
	<pre>
	  create or replace trigger ec_products_audit_tr
	  before update or delete on ec_products
	  for each row
	  begin
	  insert into ec_products_audit (
	  product_id, product_name, 
	  one_line_description, 

	  ...

	  last_modified,
	  last_modifying_user, modified_ip_address
	  ) values (
	  :old.product_id, :old.product_name, 
	  :old.one_line_description, 

	  ...

	  :old.last_modified,
	  :old.last_modifying_user, :old.modified_ip_address
	  );
	  end;
	  /
	  show errors
	</pre>
      </blockquote>

      <p>Note that it is not possible to automatically populate the
	audit table on deletion because we need the IP address of the
	deleting user.</p>
    </li>

    <li>
      <p>Change any script that deletes rows from an audited table.
	It should call <code>ec_audit_delete_row</code> with args key
	list, column name list, and audit_table_name. This procedure
	calls <code>ad_get_user_id</code> and <code>ns_conn
	  peeraddr</code> and records the user_id and IP address of the
	user deleting the row.</p>

      <blockquote>
	<pre>
	  <code>
	    db_transaction {
	    db_dml unused "delete from ec_products where product_id=$product_id"
	    ec_audit_delete_row [list $product_id] [list product_id] ec_products_audit
	    }
	  </code>
	</pre>
      </blockquote>
    </li>

    <li>
      <p>Insert a call to <code>ec_audit_trail</code> in an admin page
	to show the changes made to a key. Insert a call to
	<code>ec_audit_trail_for_table</code> to show the changes made
	to an entire table over a specified period of time.</p>
    </li>

    <li>
      <p><em>optionally</em> define two views to provide "user
	friendly" audits.  Look at the ticket
	tracker data model tables <code>ticket_pretty</code> and
	<code>ticket_pretty_audit</code> for an example.  This has the
	benefit of decoding the meaningless integer ID's and
	highlighting potential data integrity violations.</p>
    </li>
  </ul>

  <h2>Reference</h2>

  <h3>Audit columns:</h3>

  <ul>
    <li><b>last_modified</b> The date the row was last changed.</li>
    <li><b>last_modifying_user</b> The ID of the user who last changed the row.</li>
    <li><b>modified_ip_address</b> The IP Address the change request came from.</li>
    <li><b>delete_p</b> The true/false tag that indicates the audit table entry is recording information on the user who deleted a row.</li>
  </ul>

  <h3><code>ec_audit_trail_for_table</code></h3>

  <blockquote>
    <p>Returns an audit trail across an entire table, (multiple
      keys).</p>

    <ul>

      <li><b>db</b> Database handle.</li>

      <li><b>main_table_name</b> Table that holds the main record. If
	sent an empty string as main_table_name, ec_audit_trail assumes
	that the audit_table_name has all current records.</li>

      <li><b>audit_table_name</b> Table that holds the audit
	records.</li>

      <li><b>id_column</b> Column name of the primary key in
	audit_table_name and main_table_name.</li>

      <li><b>start_date</b> (optional) ANSI standard time to begin
	viewing records.</li>

      <li><b>end_date</b> (optional) ANSI standard time to stop viewing
	records.</li>

      <li><b>audit_url</b> (optional) URL of a tcl page that would
	display the full audit history of an record. Form variables for
	that page: id id_column main_table_name and
	audit_table_name.</li>

      <li><b>restore_url</b> (optional) (future improvement) <i>URL of a
	  tcl page that would restore a given record to the main
	  table. Form variables for the page: id id_column main_table_name
	  audit_table_name and rowid.</i>

    </ul>

  </blockquote>

  <h3><code>ec_audit_trail</code></h3>

  <blockquote>

    <p>Returns an audit trail of a single key in a table.</p>
    
    <ul>

      <li><b>db</b> Database handle.</li>

      <li><b>id_list</b> List of ids representing the unique record you
	are processing.</li>

      <li><b>audit_table_name</b> Table that holds the audit
	records.</li>

      <li><b>main_table_name</b> Table that holds the main record. If
	sent an empty string as main_table_name, ec_audit_trail assumes
	that the audit_table_name has all current records.</li>

      <li><b>id_column_list</b> Column names of the unique key in
	audit_table_name and main_table_name.</li>

      <li><b>columns_not_reported</b> (optional) Tcl list of column
	names in audit_table_name and main_table that you don't want
	displayed.</li>

      <li><b>start_date</b> (optional) ANSI standard time to begin
	viewing records.</li>

      <li><b>end_date</b> (optional) ANSI standard time to stop viewing
	records.</li>

      <li><b>restore_url</b> (optional) (future improvement)<i>URL of a
	  tcl page that would restore a given record to the main
	  table. Form variables for the page: id id_column main_table_name
	  audit_table_name and rowid.</i>

    </ul>

  </blockquote>  
  
  <h3><code>ec_audit_delete_row</code></h3>

  <blockquote>

    <p>Creates a row in the audit table to log when, who, and from what
      IP address a row was deleted.</p>

    <ul>

      <li><b>db</b> Database handle.</li>

      <li><b>id_list</b> Tcl list of the ids specifying the unique
	record you are processing. (Or the list of ID's in the case of a
	map table.)</li>

      <li><b>id_column_list</b> Tcl list of the column names of the
	unique key in audit_table_name.</li>

      <li><b>audit_table_name</b> Table that holds the audit
	records.</li>

    </ul>

  </blockquote>

  <h2>Future Improvements</h2>

  <p>The ec_audit_trail and ec_audit_trail_for_table procedures could
    be extended to restore previous values. The restore_url would be a
    pointer to a script that could restore an old row to the main
    table. The script would need to query the data dictionary for the
    columns of the audit and main tables. It might also require the
    user to confirm if a current record would be overwritten by the
    restore option.</p>

<master src=master>
<property name=title>Incoming Email</property>

<ol>
<b><li>Determine or create the user_identification_id and issue_id as follows.</b>
    <p>
    Incoming email will come to an email address either of the form 
    <code>service-<i>user_identification_id</i>-<i>issue_id</i>@whatever.com</code>
    or just <code>service@whatever.com</code>.
    <p>
    <ul>
    <li>Case 1: <code>service-<i>user_identification_id</i>-<i>issue_id</i>@whatever.com</code>
    <p>
    Do a check to make sure that issue actually belongs to that user (check that issue_id and 
    user_identification_id match in ec_customer_service_issues).
      <ul>
      <li>If so, just reopen the issue if it's closed.
      <li>If not, they've probably been messing with the numbers in the email address, so just
          treat it like Case 2.
      </ul>
    <p>
    <li>Case 2: <code>service@whatever.com</code>
      <ol type=a>
      <li>Determine the email address from which it came.  See if the email address belongs to a registered user of the system.
          <ul>
	  <li>If so, see if there's a user_identification_id with that user_id (only
	  grab the first one, if it exists, then flush the rest).
	     <ul>
	     <li>If so, great, we'll be using that user_identification_id later.
	     <li>If not, get a new user_identification_id (using ec_user_ident_id_sequence) and create the user_identification record (insert into ec_user_identification (user_identification_id, date_added, user_id) values ($user_identification_id, sysdate, $user_id)).
	     </ul>
	  <li>If not, see if the email address belongs to a non-registered user with a past customer service record (i.e. there's a row in ec_user_identification with that email address; only grab the first one, if it exists, then flush the rest)
	     <ul>
	     <li>If so, great, we'll be using that user_identification_id later.
	     <li>If not, insert a new row into ec_user_identification with user_identification_id, date_added, email, and, if you can regexp them out, first_names and last_name filled in.
	     </ul> 
	  </ul>
      Now we have a user_identification_id to use.
      <p>
      <li>Create a customer service issue.  Set the issue_id (you'll need it later) to ec_issue_id_sequence.nextval, and then insert into ec_customer_service_issues (issue_id, user_identification_id, open_date) values ($issue_id, $user_identification_id, sysdate).
      </ol>
      </ul>
<p>
<b><li>Create a new interaction.</b>
<p>
Just generate an interaction_id with ec_interaction_id_sequence.  Then insert into ec_customer_serv_interactions (interaction_id, user_identification_id, interaction_date, interaction_originator, interaction_type, interaction_headers) values ($interaction_id, $user_identification_id, sysdate, 'customer', 'email', [the headers from the email]).
<p>
<b><li>Create a new action.</b>
<p>
insert into ec_customer_service_actions (action_id, issue_id, interaction_id, action_details) values (ec_action_id_sequence.nextval, $issue_id, $interaction_id, [the body of the email])
</ol>


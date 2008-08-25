<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<if @doubleclicked@ true> 
	<p>You are seeing this page because you probably either tried
	reloading the page or pushed the Submit button twice.</p>
	<p>If you wonder whether the users got the email, just check the
	customer service issues for one of the users (all mail sent to a
	user is recorded as a customer service issue).</p>
</if><else>
 <p>Message:</p>
    @message@
 <p>Emailed to:</p>
 <ul>
  @spamming_users_html;noquote@
 </ul>
</else>

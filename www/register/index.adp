<master>
<property name=title>Log In</property>
<property name=focus>login.email</property>

<h2><if @http_id@ not nil>Secure </if>Log In</h2>

to <a href=@system_link@>@system_name@</a>

<hr>

<if @http_id@ not nil><p>Please login to our secure server.</if>

<p><b>Current users:</b> Please enter your email and password below.</p>
<p><b>New users:</b>  Welcome to @system_name@.  Please begin the
registration process by entering a valid email address and a
password for signing into the system.  We will direct you to another form to 
complete your registration.</p>

<FORM method=post action=user-login name=login>
@export_vars;noquote@
<table>
<tr><td>Your email address:</td><td><INPUT type=text name=email value="@email@"></tr>

<if @old_login_process@ eq 0>

 <tr><td>Your password:</td>
     <td><input type=password name=password></td></tr>
 <if @allow_persistent_login_p@ eq 1>

   <tr><td colspan=2>
 
   <if @persistent_login_p@ eq 1>
       <input type=checkbox name=persistent_cookie_p value=1 CHECKED> 
   </if>
   <else>
       <input type=checkbox name=persistent_cookie_p value=1> 
   </else>

       	Remember this address and password?
	(<a href="explain-persistent-cookies">help</a>)</td></tr>
 </if>

</if>


<tr><td colspan=2 align=center><INPUT TYPE=submit value="Submit"></td></tr>
</table>

</FORM>

<p>

If you keep getting thrown back here, it is probably because your
browser does not accept cookies.  We're sorry for the inconvenience
but it really is impossible to program a system like this without
keeping track of who is posting what.

<p>

In Netscape 4.0, you can enable cookies from Edit -&gt; Preferences
-&gt; Advanced.  In Microsoft Internet Explorer 4.0, you can enable cookies from View -&gt; Internet Options -&gt; Advanced -&gt; Security.


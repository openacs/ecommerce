<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<form method=post action=comments-edit>
<p>Please add or edit comments below:</p>

<blockquote>
<textarea name=cs_comments rows=15 cols=50 wrap>@previous_comments@</textarea>
</blockquote>

<br>
<center>
<input type=submit value="Submit">
</center>

</form>

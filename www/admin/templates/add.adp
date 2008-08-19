<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<form method=post action=add-2>
  <p>Name: <input type=text name=template_name size=30></p>
  <p>ADP template:<br>
    <textarea name=template rows=10 cols=60>@template@</textarea>
  </p>
<center>
  <input type=submit value="Submit">
</center>
</form>

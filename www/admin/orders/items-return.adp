<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<form method=post action=items-return-2>
@export_form_vars_html;noquote@
 <p>Date received back: @date_received_back_html;noquote@</p>
 <p>Please check off the items that were received back:</p>
    @items_for_return_html;noquote@
 <p>Reason for return (if known):</p>
 <textarea name=reason_for_return rows=5 cols=50 wrap></textarea>
 <center><input type=submit value="Continue"></center>
</form>

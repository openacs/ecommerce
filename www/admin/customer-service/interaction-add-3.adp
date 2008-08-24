<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<if @error_path@ eq "1">
 <p>The selected user is not the customer involved in this interaction.</p>
 <p>Would you like to make this user be the owner of this interaction?
 (If not, push Back button and fix the issue ID.)</p>
 <form method="post" action="interaction-add-3">
  @hidden_input_html;noquote@
  @export_entire_form_except_html;noquote@
  <center>
   <input type="submit" value="Yes">
  </center>
 </form>
</if><else>

<if @error_path@ eq "2">
 <p>Issue ID @issue_id@ belongs to the the non-registered person who
has had a previous interaction with us: @user_id_summary_html;noquote@
However, that user has not been selected as the customer involved in this interaction.
 </p><p>
Would you like to make this user be the owner of this interaction?
(If not, push Back button and fix the issue ID.)</p>
 <form method="post" action="interaction-add-3">
  @hidden_input_html;noquote@  @export_entire_form_html;noquote@
  <center>
   <input type="submit" value="Yes">
  </center>
 </form>
</if><else>

<if @error_path@ eq "3">
  <p>Order ID @order_id@ belongs to the registered user
  @registered_user_html;noquote@.  However, you haven't selected that user as the customer involved in this interaction.
</p><p>
Would you like to make this user be the owner of this interaction?
(If not, push Back button and fix the order ID.)
</p>
<form method="post" action="interaction-add-3">
 @hidden_input_html;noquote@  @export_entire_form_html;noquote@
  <center>
    <input type="submit" value="Yes">
  </center>
 </form>
</if><else>

<!-- no input/output here. Page should redirect -->

</else></else></else>

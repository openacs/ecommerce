<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

    <p>Please confirm new address:</p>
    <blockquote>
 @pretty_mailing_address_html;noquote@
   </blockquote>
    <form method=post action=address-add-3>
      @export_entire_form_html;noquote@
      <center>
        <input type=submit value="Confirm">
      </center>
    </form>
 

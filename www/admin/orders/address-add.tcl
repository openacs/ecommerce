ad_page_contract {
    New shipping address.

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    order_id:integer,notnull
    creditcard_id:integer,optional
}

ad_require_permission [ad_conn package_id] admin

doc_body_append "
    [ad_admin_header "New Shipping Address"]

    <h2>New Shipping Address</h2>

    [ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Orders"] [list "one?[export_url_vars order_id]" "One Order"] "New Shipping Address"]

    <hr>
    <p>Please enter a new domestic address or a new international address.  All future shipments for this order will go to this address.</p>

    <p>New domestic address:</p>"

set user_name [db_string user_name_select "
    select first_names || ' ' || last_name 
    from cc_users, ec_orders 
    where ec_orders.user_id=cc_users.user_id 
    and order_id=:order_id" -default ""]

doc_body_append "
    <blockquote>
      <form method=post action=address-add-2>
        [export_form_vars order_id creditcard_id]
        <table>
          <tr>
            <td>Name</td>
            <td><input type=text name=attn size=30 value=\"[ad_quotehtml $user_name]\"></td>
          </tr>
          <tr>
            <td>Address</td>
            <td><input type=text name=line1 size=40></td>
          </tr>
          <tr>
            <td>2nd line (optional)</td>
            <td><input type=text name=line2 size=40></td>
          </tr>
          <tr>
            <td>City</font></td>
            <td><input type=text name=city size=20> &nbsp;State [state_widget]</td>
          </tr>
          <tr>
            <td>Zip</td>
            <td><input type=text maxlength=5 name=zip_code size=5></td>
          </tr>
          <tr>
            <td>Phone</td>
            <td><input type=text name=phone size=20 maxlength=20> <input type=radio name=phone_time value=d CHECKED> day &nbsp;&nbsp;&nbsp;
                <input type=radio name=phone_time value=e> evening</td>
          </tr>
        </table>
        <center>
          <input type=submit value=\"Continue\">
        </center>
      </form>
    </blockquote>
    
    <p>New international address:</p>

    <blockquote>
      <form method=post action=address-add-2>
        [export_form_vars order_id creditcard_id]
         <table>
           <tr>
             <td>Name</td>
             <td><input type=text name=attn size=30 value=\"[ad_quotehtml $user_name]\"></td>
           </tr>
           <tr>
             <td>Address</td>
             <td><input type=text name=line1 size=50></td>
           </tr>
           <tr>
             <td>2nd line (optional)</td>
             <td><input type=text name=line2 size=50></td>
           </tr>
           <tr>
             <td>City</font></td>
             <td><input type=text name=city size=20></td>
           </tr>
           <tr>
             <td>Province or Region</td>
             <td><input type=text name=full_state_name size=15></td>
           </tr>
           <tr>
             <td>Postal Code</td>
             <td><input type=text maxlength=10 name=zip_code size=10></td>
           </tr>
           <tr>
             <td>Country</td>
             <td>[ec_country_widget]</td>
           </tr>
           <tr>
             <td>Phone</td>
             <td><input type=text name=phone size=20 maxlength=20> <input type=radio name=phone_time value=d CHECKED> day &nbsp;&nbsp;&nbsp;
                 <input type=radio name=phone_time value=e> evening</td>
           </tr>
         </table>
         <center>
           <input type=submit value=\"Continue\">
         </center>
       </form>
     </blockquote>

    [ad_admin_footer]"



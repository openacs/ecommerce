ad_page_contract {

    Add an item to an order.

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    order_id:integer,notnull
}

ad_require_permission [ad_conn package_id] admin

doc_body_append "
    [ad_admin_header "Add Items"]

    <h2>Add Items</h2>

    [ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Orders"] [list "one?order_id=$order_id" "One Order"] "Add Items"]

    <hr>
    <blockquote>
    <p>Search for a product to add:</p>
      <form method=post action=items-add-2>
        [export_form_vars order_id]
        <ul>
          <li>By Name: <input type=text name=product_name size=20> <input type=submit value=\"Search\"></li>
        </ul>
      </form>
      <form method=post action=items-add-2>
        [export_form_vars order_id]
        <ul>    
          <li>By SKU: <input type=text name=sku size=3> <input type=submit value=\"Search\"></li>
        </ul>
      </form>
    </blockquote>
    [ad_admin_footer]"


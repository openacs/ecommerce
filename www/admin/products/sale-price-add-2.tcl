ad_page_contract {

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    sale_price_id:integer,notnull
    product_id:integer,notnull
    sale_price:notnull
    sale_name:html
    sale_begins
    sale_ends
    offer_code
}

ad_require_permission [ad_conn package_id] admin

# We need them to be logged in

set user_id [ad_get_user_id]

# See if a sale price with this sale_price_id exists, meaning they
# pushed submit twice

if { [db_string doubleclick_select "
    select count(*) 
    from ec_sale_prices
    where sale_price_id = :sale_price_id"] > 0 } {
    ad_returnredirect "sale-prices.tcl?[export_url_vars product_id product_name]"
}

set peeraddr [ns_conn peeraddr]

db_dml sale_insert "
    insert into ec_sale_prices
    (sale_price_id, product_id, sale_price, sale_begins, sale_ends, sale_name, offer_code, last_modified, last_modifying_user, modified_ip_address)
    values
    (:sale_price_id, :product_id, :sale_price, to_date(:sale_begins,'YYYY-MM-DD HH24:MI:SS'), to_date(:sale_ends,'YYYY-MM-DD HH24:MI:SS'), :sale_name, :offer_code, sysdate, :user_id, :peeraddr)"

ad_returnredirect "sale-prices.tcl?[export_url_vars product_id product_name]"

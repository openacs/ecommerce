ad_page_contract {

    Insert the address.

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    order_id:integer,notnull
    {creditcard_id:integer ""}
    attn
    line1
    line2
    city
    {usps_abbrev ""}
    {full_state_name ""}
    zip_code
    {country_code "US"}
    phone
    phone_time
}

ad_require_permission [ad_conn package_id] admin

if {[empty_string_p $creditcard_id]} {

    # Insert the address into ec_addresses, update the address in
    # ec_orders

    db_transaction {
	set address_id [db_nextval ec_address_id_sequence]
	set user_id [db_string user_id_select "
	    select user_id 
	    from ec_orders 
	    where order_id = :order_id"]

	db_dml address_insert "
	    insert into ec_addresses
	    (address_id, user_id, address_type, attn, line1, line2, city, usps_abbrev, full_state_name, zip_code, country_code, phone, phone_time)
	    values
	    (:address_id, :user_id, 'shipping', :attn, :line1, :line2, :city, :usps_abbrev, :full_state_name, :zip_code, :country_code, :phone, :phone_time)"

	db_dml ec_orders_update "
	    update ec_orders
	    set shipping_address = :address_id
	    where order_id = :order_id"
    }
} else {

    # Insert the address into ec_addresses, update the address in
    # ec_creditcards

    db_transaction {
	set address_id [db_nextval ec_address_id_sequence]
	set user_id [db_string user_id_select "
	    select user_id 
	    from ec_orders 
	    where order_id = :order_id"]

	db_dml address_insert "
	    insert into ec_addresses
	    (address_id, user_id, address_type, attn, line1, line2, city, usps_abbrev, full_state_name, zip_code, country_code, phone, phone_time)
	    values
	    (:address_id, :user_id, 'shipping', :attn, :line1, :line2, :city, :usps_abbrev, :full_state_name, :zip_code, :country_code, :phone, :phone_time)"

	db_dml ec_creditcards_update "
	    update ec_creditcards
	    set billing_address = :address_id
	    where creditcard_id = :creditcard_id"
    }
}

ad_returnredirect "one?[export_url_vars order_id]"

ad_page_contract {

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002

} {
    address_id
    order_id:notnull
    creditcard_number:notnull
    creditcard_type:notnull
    creditcard_expire_1
    creditcard_expire_2
}

ad_require_permission [ad_conn package_id] admin

db_transaction {
    set user_id [db_string user_id_select "
	select user_id 
	from ec_orders 
	where order_id = :order_id"]
    set creditcard_id [db_nextval ec_creditcard_id_sequence]
    set creditcard_last_four [string range $creditcard_number [expr [string length $creditcard_number] -4] [expr [string length $creditcard_number] -1]]
    set creditcard_expire "$creditcard_expire_1/$creditcard_expire_2"
    db_dml creditcard_insert_select "
	insert into ec_creditcards
  	(creditcard_id, user_id, creditcard_number, creditcard_last_four, creditcard_type, creditcard_expire, billing_address)
  	values
  	(:creditcard_id, :user_id, :creditcard_number, :creditcard_last_four, :creditcard_type, :creditcard_expire, :address_id)"
    db_dml ec_orders_update "
	update ec_orders 
	set creditcard_id = :creditcard_id 
	where order_id = :order_id"
}
ad_returnredirect "one?[export_url_vars order_id]"

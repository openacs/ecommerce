#  www/ecommerce/delete-shipping-address.tcl
ad_page_contract {
    @param address_id
    @author Bart Teeuwisse <bart.teeuwisse@7-sisters.com>
    @creation-date
    @cvs-id shipping-address-2.tcl,v 3.2.6.7 2000/08/18 21:46:35 stevenp Exp
} {
    address_id
}

# Can't remove the address from the database as old orders might refer to the address.
# By setting the address_type to 'deleted' the address will no longer be available for
# shipping. While still in the database the user can't use the address any more.
db_dml delete_address "update ec_addresses set address_type='deleted' where address_id=:address_id"

# Return to the first step in the checkout process.
ad_returnredirect [ec_securelink [ec_url]checkout]

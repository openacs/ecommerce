select acs_sc_impl__delete(
	   'FtsContentProvider',		-- impl_contract_name
           'ec_product'				-- impl_name
);

drop trigger ec_products__utrg on ec_products;
drop trigger ec_products__dtrg on ec_products;
drop trigger ec_products__itrg on ec_products;

drop function ec_products__utrg ();
drop function ec_products__dtrg ();
drop function ec_products__itrg ();


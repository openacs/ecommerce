select acs_sc_impl__new(
           'FtsContentProvider',		-- impl_contract_name
           'Ecommerce_Product',	               	-- impl_name
           'ecommerce'				-- impl_owner_name
);

select acs_sc_impl_alias__new(
           'FtsContentProvider',		-- impl_contract_name
           'Ecommerce_Product',			-- impl_name
           'datasource',			-- impl_operation_name
           'ec_products__datasource',		-- impl_alias
           'TCL'				-- impl_pl
);

select acs_sc_impl_alias__new(
           'FtsContentProvider',		-- impl_contract_name
           'Ecommerce_Product',			-- impl_name
           'url',				-- impl_operation_name
           'ec_products__url',			-- impl_alias
           'TCL'				-- impl_pl
);


create function ec_products__itrg ()
returns opaque as '
begin
    perform search_observer__enqueue(new.product_id,''INSERT'');
    return new;
end;' language 'plpgsql';

create function ec_products__dtrg ()
returns opaque as '
begin
    perform search_observer__enqueue(old.product_id,''DELETE'');
    return old;
end;' language 'plpgsql';

create function ec_products__utrg ()
returns opaque as '
begin
    perform search_observer__enqueue(old.product_id,''UPDATE'');
    return old;
end;' language 'plpgsql';


create trigger ec_products__itrg after insert on ec_products
for each row execute procedure ec_products__itrg ();

create trigger ec_products__dtrg after delete on ec_products
for each row execute procedure ec_products__dtrg ();

create trigger ec_products__utrg after update on ec_products
for each row execute procedure ec_products__utrg ();



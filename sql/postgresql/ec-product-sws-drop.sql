-- ec-product-sws-drop.sql
--
-- @author Walter McGinnis (wtem@olywa.net)
--
-- @creation_date 2001-03-26
--
-- drop PL/SQL package for the ec_products object_type
-- and that sets up site-wide-search
--
-- $ID:$

begin
    acs_interface.remove_obj_type_impl (
	    interface_name          => 'sws_display' ,
	    programming_language    => 'pl/sql'      ,
	    object_type             => 'ec_product'
    );

    acs_interface.remove_obj_type_impl (
	    interface_name          => 'sws_indexing' ,
	    programming_language    => 'pl/sql'      ,
	    object_type             => 'ec_product'
    );	
end;
/

drop package ec_product_sws;

begin
    pot_service.delete_obj_type_attr_value (
	    package_key		    => 'ecommerce'	,
	    object_type		    => 'ec_product'	,
	    attribute		    => 'display_page'
    );

    pot_service.unregister_object_type (
	    package_key		    => 'ecommerce'	,
	    object_type		    => 'ec_product'
    );
end;
/

drop trigger ec_product_itrg;

drop trigger ec_product_utrg;

drop trigger ec_product_dtrg;




-- ecommerce/sql/ec-product-package-create.sql
--
-- @author Walter McGinnis (wtem@olywa.net)
--
-- @creation_date 2001-03-24
--
-- $ID:$
--
-- ec_product pl/sql package spec and body

-- ported to OpenACS 4.x by Gilbert Wong (gwong@orchardlabs.com)

-- note: this package doesn't handle custom fields...
-- in the tcl pages, you'll want to make sure that is handled separately

-- gilbertw - PostgreSQL only supports 16 parameters
-- use an update in the tcl script on the returned object id
-- start a transaction for the new product creation
create function ec_product__new (integer,integer,integer,varchar,numeric,varchar,varchar,varchar,varchar,boolean,char,varchar,timestamp,varchar,varchar,varchar)
returns integer as '
declare
  new__product_id		alias for $1;  -- default null
  new__creation_user		alias for $2;  -- default null
  new__context_id		alias for $3;  -- default null (package_id)
  new__product_name  		alias for $4; 
  new__price			alias for $5;  -- default null
  new__sku			alias for $6;  -- default null
  new__one_line_description	alias for $7;  -- default null
  new__detailed_description	alias for $8;  -- default null
  new__search_keywords		alias for $9;  -- default null
  new__present_p		alias for $10; -- default t
  new__stock_status		alias for $11; -- default o
  new__dirname			alias for $12; -- default null
  new__available_date		alias for $13; -- default sysdate
  new__color_list		alias for $14; -- default null
  new__size_list		alias for $15; -- default null
  new__style_list		alias for $16; -- default null
  -- new__email_on_purchase_list	alias for $17; -- default null
  -- new__url			alias for $17; -- default null
  -- new__no_shipping_avail_p	alias for $19; -- default f
  -- new__shipping			alias for $20; -- default null
  -- new__shipping_additional	alias for $21; -- default null
  -- new__weight			alias for $22; -- default null
  -- new__active_p			alias for $23; -- default t
  -- new__template_id		alias for $24; -- default null
  -- new__announcements		alias for $25; -- default null
  -- new__announcements_expire	alias for $26; -- default null
  v_object_id			integer;
 begin
     v_object_id := acs_object__new (
	new__product_id,
	''ec_product'',
	now(),
        new__creation_user,
	null,
	new__context_id
     );
     insert into ec_products 
     (product_id, creation_date, last_modified, last_modifying_user, modified_ip_address, product_name, price, sku, one_line_description, detailed_description, search_keywords, present_p, stock_status, dirname, available_date, color_list, size_list, style_list)
     values 
     (v_object_id, new__creation_date, new__creation_date, new__creation_user, new__creation_ip, new__product_name, new__price, new__sku, new__one_line_description, new__detailed_description, new__search_keywords, new__present_p, new__stock_status, new__dirname, new__available_date, new__color_list, new__size_list, new__style_list);

     -- to be used when PostgreSQL supports more than 16 parameters
     -- insert into ec_products 
     -- (product_id, creation_date, last_modified, last_modifying_user, modified_ip_address, product_name, price, sku, one_line_description, detailed_description, search_keywords, present_p, stock_status, dirname, available_date, color_list, size_list, style_list, email_on_purchase_list, url, no_shipping_avail_p, shipping, shipping_additional, weight, active_p, template_id, announcements, announcements_expire)
     -- values 
     -- (v_object_id, new__creation_date, new__creation_date, new__creation_user, new__creation_ip, new__product_name, new__price, new__sku, new__one_line_description, new__detailed_description, new__search_keywords, new__present_p, new__stock_status, new__dirname, new__available_date, new__color_list, new__size_list, new__style_list, new__email_on_purchase_list, new__url, new__no_shipping_avail_p, new__shipping, new__shipping_additional, new__weight, new__active_p, new__template_id, new__announcements, new__announcements_expire);

     return v_object_id;

end;' language 'plpgsql';


create function ec_product__delete (integer)
returns integer as '
declare
    delete__product_id		alias for $1;
begin
    delete from ec_products
    where product_id = delete__product_id;

    PERFORM acs_object__delete(delete__product_id);
    return 0;
end;' language 'plpgsql';



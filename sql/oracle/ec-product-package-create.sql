-- ecommerce/sql/ec-product-package-create.sql
--
-- @author Walter McGinnis (wtem@olywa.net)
--
-- @creation_date 2001-03-24
--
-- $ID:$
--
-- ec_product pl/sql package spec and body

-- note: this package doesn't handle custom fields...
-- in the tcl pages, you'll want to make sure that is handled separately
create or replace package ec_product
as

 function new (
  product_id		in acs_objects.object_id%TYPE			default null,
  object_type		in acs_objects.object_type%TYPE			default 'ec_product',
  creation_date		in acs_objects.creation_date%TYPE		default sysdate,
  creation_user		in acs_objects.creation_user%TYPE		default null,
  creation_ip		in acs_objects.creation_ip%TYPE			default null,
  context_id		in acs_objects.context_id%TYPE			default null,
  product_name		in ec_products.product_name%TYPE,
  price			in ec_products.price%TYPE			default null,
  sku			in ec_products.sku%TYPE				default null,
  one_line_description  in ec_products.one_line_description%TYPE	default null,
  detailed_description	in ec_products.detailed_description%TYPE	default null,
  search_keywords	in ec_products.search_keywords%TYPE		default null,
  present_p		in ec_products.present_p%TYPE			default 't',
  stock_status		in ec_products.stock_status%TYPE		default 'o',
  dirname		in ec_products.dirname%TYPE			default null,
  available_date	in ec_products.available_date%TYPE		default sysdate,
  color_list		in ec_products.color_list%TYPE			default null,
  size_list		in ec_products.size_list%TYPE			default null,
  style_list		in ec_products.style_list%TYPE			default null,
  email_on_purchase_list in ec_products.email_on_purchase_list%TYPE	default null,
  url			in ec_products.url%TYPE				default null,
  no_shipping_avail_p   in ec_products.no_shipping_avail_p%TYPE		default 'f',
  shipping		in ec_products.shipping%TYPE			default null,
  shipping_additional	in ec_products.shipping_additional%TYPE		default null,
  weight		in ec_products.weight%TYPE			default null,
  active_p		in ec_products.active_p%TYPE			default 't',
  template_id		in ec_products.template_id%TYPE			default null,
  announcements		in ec_products.announcements%TYPE		default null, 
  announcements_expire  in ec_products.announcements_expire%TYPE	default null
 ) return acs_objects.object_id%TYPE;

 procedure delete (
  product_id in ec_products.product_id%TYPE
 );

end;
/
show errors


create or replace package body ec_product
as
 function new (
  product_id		in acs_objects.object_id%TYPE			default null,
  object_type		in acs_objects.object_type%TYPE			default 'ec_product',
  creation_date		in acs_objects.creation_date%TYPE		default sysdate,
  creation_user		in acs_objects.creation_user%TYPE		default null,
  creation_ip		in acs_objects.creation_ip%TYPE			default null,
  context_id		in acs_objects.context_id%TYPE			default null,
  product_name		in ec_products.product_name%TYPE,
  price			in ec_products.price%TYPE			default null,
  sku			in ec_products.sku%TYPE				default null,
  one_line_description  in ec_products.one_line_description%TYPE	default null,
  detailed_description	in ec_products.detailed_description%TYPE	default null,
  search_keywords	in ec_products.search_keywords%TYPE		default null,
  present_p		in ec_products.present_p%TYPE			default 't',
  stock_status		in ec_products.stock_status%TYPE		default 'o',
  dirname		in ec_products.dirname%TYPE			default null,
  available_date	in ec_products.available_date%TYPE		default sysdate,
  color_list		in ec_products.color_list%TYPE			default null,
  size_list		in ec_products.size_list%TYPE			default null,
  style_list		in ec_products.style_list%TYPE			default null,
  email_on_purchase_list in ec_products.email_on_purchase_list%TYPE	default null,
  url			in ec_products.url%TYPE				default null,
  no_shipping_avail_p   in ec_products.no_shipping_avail_p%TYPE		default 'f',
  shipping		in ec_products.shipping%TYPE			default null,
  shipping_additional	in ec_products.shipping_additional%TYPE		default null,
  weight		in ec_products.weight%TYPE			default null,
  active_p		in ec_products.active_p%TYPE			default 't',
  template_id		in ec_products.template_id%TYPE			default null,
  announcements		in ec_products.announcements%TYPE		default null, 
  announcements_expire  in ec_products.announcements_expire%TYPE	default null
 ) return acs_objects.object_id%TYPE
 is
     v_object_id acs_objects.object_id%TYPE;
 begin
     v_object_id := acs_object.new (
         object_id => product_id,
         object_type => object_type,
         creation_date => creation_date,
         creation_user => creation_user,
         creation_ip => creation_ip,
         context_id => context_id
     );
     insert into ec_products 
     (product_id, creation_date, last_modified, last_modifying_user, modified_ip_address, product_name, price, sku, one_line_description, detailed_description, search_keywords, present_p, stock_status, dirname, available_date, color_list, size_list, style_list, email_on_purchase_list, url, no_shipping_avail_p, shipping, shipping_additional, weight, active_p, template_id, announcements, announcements_expire)
     values 
     (v_object_id, creation_date, creation_date, creation_user, creation_ip, product_name, price, sku, one_line_description, detailed_description, search_keywords, present_p, stock_status, dirname, available_date, color_list, size_list, style_list, email_on_purchase_list, url, no_shipping_avail_p, shipping, shipping_additional, weight, active_p, template_id, announcements, announcements_expire);
     return v_object_id;
 end new;

 procedure delete (
  product_id in ec_products.product_id%TYPE
 )
 is
 begin
     delete from ec_products
         where product_id = ec_product.delete.product_id;
     acs_object.delete(product_id);
 end delete;

end ec_product;
/
show errors

-- ec-product-sws-setup.sql
--
-- @author Walter McGinnis (wtem@olywa.net)
--
-- @creation_date 2001-03-24
--
-- create PL/SQL package for the ec_products object_type
-- and sets up site-wide-search
--
-- $ID:$

-- note: this requires that you are using a version of the E-commerce package
-- that has ec_products as an object-type in ecommerce-create.sql
-- obviously, the site-wide-search package has to be setup, too!

create or replace package ec_product_sws
is
    function sws_title (
	object_id		in acs_objects.object_id%type
    ) return varchar2;

    function sws_url (
	object_id           in acs_objects.object_id%type
    ) return varchar2;

    function sws_summary (
	object_id		in acs_objects.object_id%type
    ) return varchar2;    

    function sws_req_permission (
	object_id		in acs_objects.object_id%type
    ) return varchar2;

    function sws_site_node_id (
	object_id           in acs_objects.object_id%type
    ) return site_nodes.node_id%TYPE;

    function sws_application_id (
	object_id	    in acs_objects.object_id%type
    ) return apm_packages.package_id%TYPE;
    
--    procedure sws_index_proc (
--       object_id	    in acs_objects.object_id%type,
--       bdata		in out nocopy BLOB
--   );

end ec_product_sws;
/
show errors

create or replace package body ec_product_sws
is
    function sws_title (
	object_id		in acs_objects.object_id%type
    ) return varchar2
    is
	v_title		varchar2(1000);
    begin

	select product_name into v_title 
	from ec_products
	where product_id = object_id;

	return v_title;
    end;

function sws_url (
	 object_id           in acs_objects.object_id%type
    ) return varchar2
    is        
        url                     varchar2(3000);     
    begin 
        url := sws_service_interface.sws_url (
               object_id            => object_id 
        );
        return url||to_char(object_id);
    end;

    function sws_summary (
	object_id		in acs_objects.object_id%type
    ) return varchar2
    is
	v_summary	    varchar2(4000);
    begin
	select one_line_description into v_summary
	from ec_products
	where product_id = object_id;

	return v_summary;
    end sws_summary;

    -- permissions aren't explicitly used in the ecommerce package
    -- at this time
    function sws_req_permission (
	object_id		in acs_objects.object_id%type
    ) return varchar2 
    is
    begin
	return null;
    end;

    function sws_site_node_id (
        object_id           in acs_objects.object_id%type
    ) return site_nodes.node_id%TYPE
    is
        node_id             site_nodes.node_id%type;
    begin
        node_id := sws_service_interface.sws_site_node_id (
                        object_id           => object_id
                   );
        return node_id;         
    end;

    function sws_application_id (
        object_id           in acs_objects.object_id%type
    ) return apm_packages.package_id%TYPE
    is
        v_application_id        apm_packages.package_id%type;
    begin
        v_application_id := sws_service_interface.sws_application_id (
                                object_id       => object_id
                            );
        return v_application_id;
    end;

    -- wtem@olywa.net, 2001-03-24
    -- there are no blobs for ec_products at this point
    -- only detailed_description column varchar(4000)
    -- and search_keywords column varchar(4000)
    -- want to concat both and shove into blob
    -- need to change "bdata in out nocopy blob" to actual copy i think
    -- and figure out how to make sws search sws search acs_contents
    -- instead of ec_products
    -- unless sws searches all columns of ec_products


end ec_product_sws;
/
show errors

-- register the sws interface, etc

begin
  acs_interface.assoc_obj_type_with_interface (
	    interface_name          => 'sws_display' ,
	    programming_language    => 'pl/sql'      ,
	    object_type             => 'ec_product',
	    object_type_imp	    => 'ec_product_sws'  
       );
end;
/
show errors

-- need to correlate  "where present_p = 't'" 
-- to searchable_p into acs_contents
-- should check other sws enabled package that
-- don't store their content acs_contents
-- how they handle blob
-- what we would like to do is create a blob 
-- by concatinating detailed_description and search_keywords
-- from ec_products
-- and shove it in acs_contents
-- the insert and update triggers below
-- need to be altered to handle the above scenario
create or replace trigger ec_product_itrg
after insert on ec_products
for each row
declare
    v_string    varchar2(4000);
    v_bdata     blob;
    v_bdata2    blob;
    v_size      integer;
begin
     insert into acs_contents (
        content_id,
        searchable_p, 
	content
     ) values ( 
        :new.product_id,
        :new.present_p,
	empty_blob()
    );
      
      v_string := (:new.product_name||' '||:new.one_line_description||' '||:new.detailed_description||' '||:new.search_keywords||' '||to_char(:new.price));
       
      select content into v_bdata2
      from acs_contents
      where content_id = :new.product_id for update;

      dbms_lob.createtemporary(v_bdata, TRUE);

      string_to_blob(v_string, v_bdata);
      v_size := dbms_lob.getlength(v_bdata);

      if v_size > 0 then 
          dbms_lob.copy (
              dest_lob    => v_bdata2,
              src_lob     => v_bdata,
              amount      => v_size
          );
      end if;
 end;
/
show errors

-- not sure about mime_type, nls_language
-- whether they should be included here
-- nls_language    = :new.nls_language,
-- mime_type       = :new.mime_type,

create or replace trigger ec_product_utrg
after update on ec_products
for each row
declare
    v_string    varchar2(4000);
    v_bdata     blob;
    v_bdata2    blob;
    v_size      integer;
begin
    update acs_contents 
    set	 searchable_p = :new.present_p
    where content_id = :new.product_id;

    v_string := (:new.product_name||' '||:new.one_line_description||' '||:new.detailed_description||' '||:new.search_keywords||' '||to_char(:new.price));
       
    select content into v_bdata2
    from acs_contents
    where content_id = :new.product_id for update;

    dbms_lob.createtemporary(v_bdata, TRUE);

    string_to_blob(v_string, v_bdata);
    v_size := dbms_lob.getlength(v_bdata);

    if v_size > 0 then 
        dbms_lob.copy (
            dest_lob    => v_bdata2,
            src_lob     => v_bdata,
            amount      => v_size
        );
    end if;

end;
/
show errors

create or replace trigger ec_product_dtrg
after delete on ec_products
for each row
declare
begin
    delete from acs_contents
    where content_id = :old.product_id;
end;
/
show errors

-- begin
  -- acs_interface.assoc_obj_type_with_interface (
	--     interface_name          => 'sws_indexing' ,
	   --  programming_language    => 'pl/sql'      ,
	    -- object_type             => 'ec_product',
	    -- object_type_imp	    => 'ec_product_sws'  
--     );
-- end;
-- /
-- show errors

begin
    pot_service.register_object_type (
	package_key		=> 'ecommerce',
	object_type		=> 'ec_product'
    );

    pot_service.set_obj_type_attr_value (
	package_key		=> 'ecommerce',
	object_type		=> 'ec_product',
	attribute		=> 'display_page',
	attribute_value		=> 'product?product_id='
    );    

    sws_service.update_content_obj_type_info ('ec_product');
    sws_service.rebuild_index;
end;
/
show errors



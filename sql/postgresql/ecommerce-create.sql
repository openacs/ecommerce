--
-- ecommerce-create.sql
--
-- by eveander@arsdigita.com, April 1999
-- and ported by Jerry Asher (jerry@theashergroup.com) 
-- and Walter McGinnis (wtem@olywa.net)
--
-- ported to OpenACS by Gilbert wong (gwong@orchardlabs.com)
-- July 2001
-- OpenFTS Search added by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
--
-- Besides the tables defined here, you also need to import
-- zip_codes, which contains the following columns:
--  ZIP_CODE                               NOT NULL VARCHAR2(10)
--  STATE_CODE                                      CHAR(2)
--  CITY_NAME                                       VARCHAR2(32)
--  COUNTY_NAME                                     VARCHAR2(32)
--  LONGITUDE                                       NUMBER(9,6)
--  LATITUDE                                        NUMBER(9,6)


-- Each table in ecommerce has a column for user_id, ip_address, 
-- creation_date and last_modified to assist in auditing user
-- inserts, updates, and deletes.
-- Audit tables store information about entries in the main ec_ tables.
-- They have an column for each column of the main table, plus
-- a column for marking when a logged entry was for a deleted row.

-- gilbertw: acs-references is not complete yet.  use old acs-geo-tables until
-- acs-references is done

-- product display templates
create sequence ec_template_id_seq start 2;
create view ec_template_id_sequence as select nextval('ec_template_id_seq') as nextval;

-- Helper stuff (ben@adida.net)
-- gilbertw - I pulled this from OpenACS 3.2.5
-- there are a few calls to the Oracle least function
-- least removed since now included with postgresql by default

-- gilbertw
-- timespan_days taken from OpenACS 3.2.5
-- can't cast numeric to varchar/text so I made the input varchar
create function timespan_days(float) returns interval as '
DECLARE
        n_days alias for $1;
BEGIN
        return (n_days::text || '' days'')::interval;
END;
' language 'plpgsql';


-- I should have named this product_templates because now we
-- have other kinds of templates.

create table ec_templates (
        template_id             integer not null primary key,
        template_name           varchar(200),
        template                varchar(4000),
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null
);

create table ec_templates_audit (
        template_id             integer,
        template_name           varchar(200),
        template                varchar(4000),
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f'
);

-- A trigger is used to move information from the main table to 
-- the audit table
create function ec_templates_audit_tr () 
returns opaque as '
begin
        insert into ec_templates_audit (
        template_id, template_name,
        template,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.template_id,
        old.template_name, old.template,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address      
        );
	return new;
end;' language 'plpgsql';

create trigger ec_templates_audit_tr
after update or delete on ec_templates
for each row execute procedure ec_templates_audit_tr ();

-- this is where the ec_templates insert was

-- product categories and subcategories and subsubcategories
create sequence ec_category_id_seq;
create view ec_category_id_sequence as select nextval('ec_category_id_seq') as nextval;

create table ec_categories (
        category_id             integer not null primary key,
        -- pretty, human-readable
        category_name           varchar(100),
        sort_key                numeric,
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null
);

create index ec_categories_sort_idx on ec_categories (sort_key);

create table ec_categories_audit (
        category_id             integer,
        category_name           varchar(100),
        sort_key                numeric,
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f'
);

create function ec_categories_audit_tr ()
returns opaque as '
begin
        insert into ec_categories_audit (
        category_id, category_name, sort_key,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.category_id, old.category_name, old.sort_key,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address      
        );
	return new;
end;' language 'plpgsql';

create trigger ec_categories_audit_tr
after update or delete on ec_categories
for each row execute procedure ec_categories_audit_tr ();

create sequence ec_subcategory_id_seq;
create view ec_subcategory_id_sequence as select nextval('ec_subcategory_id_seq') as nextval;


create table ec_subcategories (
        subcategory_id          integer not null primary key,
        category_id             integer not null references ec_categories,
        -- pretty, human-readable
        subcategory_name        varchar(100),
        sort_key                numeric,
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null
);

create index ec_subcategories_idx on ec_subcategories (category_id);
create index ec_subcategories_idx2 on ec_subcategories (sort_key);

create table ec_subcategories_audit (
        subcategory_id          integer,
        category_id             integer,
        subcategory_name        varchar(100),
        sort_key                numeric,
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f'
);

create function ec_subcategories_audit_tr ()
returns opaque as '
begin
        insert into ec_subcategories_audit (
        subcategory_id, category_id,
        subcategory_name, sort_key,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.subcategory_id, old.category_id,
        old.subcategory_name, old.sort_key,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address              
        );
	return new;
end;' language 'plpgsql';

create trigger ec_subcategories_audit_tr
after update or delete on ec_subcategories
for each row execute procedure ec_subcategories_audit_tr ();

-- a view with category_name also

create view ec_subcategories_augmented 
as
select subs.*, cats.category_name
from ec_subcategories subs, ec_categories cats
where subs.category_id = cats.category_id;

create sequence ec_subsubcategory_id_seq;
create view ec_subsubcategory_id_sequence as select nextval('ec_subsubcategory_id_seq') as nextval;

create table ec_subsubcategories (
        subsubcategory_id       integer not null primary key,
        subcategory_id          integer not null references ec_subcategories,
        -- pretty, human-readable
        subsubcategory_name     varchar(100),
        sort_key                numeric,
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null
);

create index ec_subsubcategories_idx on ec_subsubcategories (subcategory_id);
create index ec_subsubcategories_idx2 on ec_subsubcategories (sort_key);


create table ec_subsubcategories_audit (
        subsubcategory_id       integer,
        subcategory_id          integer,
        subsubcategory_name     varchar(100),
        sort_key                numeric,
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f'
);

create function ec_subsubcategories_audit_tr ()
returns opaque as '
begin
        insert into ec_subsubcategories_audit (
        subsubcategory_id, subcategory_id,
        subsubcategory_name, sort_key,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.subsubcategory_id, old.subcategory_id,
        old.subsubcategory_name, old.sort_key,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address              
        );
	return new;
end;' language 'plpgsql';

create trigger ec_subsubcategories_audit_tr
after update or delete on ec_subsubcategories
for each row execute procedure ec_subsubcategories_audit_tr ();

-- a view with full subcategory and category info as well 
create view ec_subsubcategories_augmented
as
select subsubs.*, subs.subcategory_name, cats.category_id, cats.category_name
from ec_subsubcategories subsubs, ec_subcategories subs, ec_categories cats
where subsubs.subcategory_id = subs.subcategory_id
and subs.category_id = cats.category_id;


-- this should be replaced by the object_id sequence
-- grep for it in files...
-- create sequence ec_product_id_sequence start 1;

-- This table contains the products and also the product series.
-- A product series has the same fields as a product (it actually
-- *is* a product, since it's for sale, has its own price, etc.).
-- The only difference is that it has other products associated
-- with it (that are part of it).  So information about the
-- whole series is kept in this table and the product_series_map
-- table below keeps track of which products are inside each
-- series. 

-- wtem@olywa.net, 2001-03-24
-- begin  
--        acs_object_type__create_type ( 
--              supertype     => 'acs_object', 
--              object_type   => 'ec_product', 
--              pretty_name   => 'Product', 
--              pretty_plural => 'Products', 
--              table_name    => 'EC_PRODUCTS', 
--              id_column     => 'PRODUCT_ID',
-- 	     package_name  => 'ECOMMERCE'
--        ); 
-- end;
-- /
-- show errors;

create function inline_0 ()
returns integer as '
begin

  PERFORM acs_object_type__create_type (
    ''ec_product'',
    ''Product'',
    ''Products'',
    ''acs_object'',
    ''ec_products'',
    ''product_id'',
    ''ecommerce'',
    ''f'',
    null,
    null
   );

  return 0;

end;' language 'plpgsql';

select inline_0 ();
drop function inline_0 ();

-- wtem@olywa.net, 2001-03-24
-- we aren't going to bother to define all the attributes of an ec_product type
-- for now, because we are just using it for site-wide-search anyway
-- we have a corresponding pl/sql package for the ec_product object_type
-- it can be found at ecommerce/sql/ec-product-package-create.sql
-- and is called at the end of this script
create table ec_products (
        product_id              integer constraint ec_products_product_id_fk
				references acs_objects(object_id)
				on delete cascade
				constraint ec_products_product_id_pk
				primary key,
	-- above changed by wtem@olywa.net, 2001-03-24
	                        -- integer not null primary key,
        sku                     varchar(100),
        product_name            varchar(200),
        creation_date           timestamptz default current_timestamp not null,
        one_line_description    varchar(400),
        detailed_description    varchar(4000),
        search_keywords         varchar(4000),
        -- this is the regular price for the product.  If user
        -- classes are charged a different price, it should be
        -- specified in ec_product_user_class_prices
        price                   numeric, 
        -- for stuff that can't be shipped like services
        no_shipping_avail_p     boolean default 'f',
        -- leave this blank if shipping is calculated using
        -- one of the more complicated methods available
        shipping                numeric,
        -- fill this in if shipping is calculated by: above price
        -- for first item (with this product_id), and the below
        -- price for additional items (with this product_id)
        shipping_additional     numeric,
        -- fill this in if shipping is calculated using weight
        -- use whatever units you want (lbs/kg), just be consistent
        -- and make your shipping algorithm take the units into
        -- account
        weight                  numeric,
        -- holds pictures, sample chapters, etc.
	dirname                 varchar(200),
        -- whether this item should show up in searches (e.g., if it's
        -- a volume of a series, you might not want it to)
        present_p               boolean default 't',
        -- whether the item should show up at all in the user pages
        active_p                boolean default 't',
        -- the date the product becomes available for sale (it can be listed
        -- before then, it's just not buyable)
	available_date          timestamptz default current_timestamp not null,
        announcements           varchar(4000),
        announcements_expire    timestamptz,
        -- if there's a web site with more info about the product
        url                     varchar(300),
        template_id             integer references ec_templates,
        -- o = out of stock, q = ships quickly, m = ships
        -- moderately quickly, s = ships slowly, i = in stock
        -- with no message about the speed of the shipment (shipping
        -- messages are in parameters .ini file)
        stock_status            char(1) check (stock_status in ('o','q','m','s','i')),
        -- comma-separated lists of available colors, sizes, and styles for the user
        -- to choose upon ordering
        color_list              varchar(4000),
        size_list               varchar(4000),
        style_list              varchar(4000),
        -- email this list on purchase
        email_on_purchase_list  varchar(4000),
        -- the user ID and IP address of the creator of the product
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null    
);

create view ec_products_displayable
as
select * from ec_products
where active_p='t';

create view ec_products_searchable
as
select * from ec_products
where active_p='t' and present_p='t';

create table ec_products_audit (
        product_id              integer,
        product_name            varchar(200),
        creation_date           timestamptz,
        one_line_description    varchar(400),
        detailed_description    varchar(4000),
        search_keywords         varchar(4000),
        price                   numeric,
        shipping                numeric,
        shipping_additional     numeric,
        weight                  numeric,
        dirname                 varchar(200),
        present_p               boolean default 't',
        active_p                boolean default 't',
        available_date          timestamptz,
        announcements           varchar(4000),
        announcements_expire    timestamptz,
        url                     varchar(300),
        template_id             integer,
        stock_status            char(1) check (stock_status in ('o','q','m','s','i')),
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f'
);

create function ec_products_audit_tr ()
returns opaque as '
begin
        insert into ec_products_audit (
        product_id, product_name, creation_date,
        one_line_description, detailed_description,
        search_keywords, shipping,
        shipping_additional, weight,
        dirname, present_p,
        active_p, available_date,
        announcements, announcements_expire, 
        url, template_id,
        stock_status,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.product_id, old.product_name, old.creation_date,
        old.one_line_description, old.detailed_description,
        old.search_keywords, old.shipping,
        old.shipping_additional, old.weight,
        old.dirname, old.present_p,
        old.active_p, old.available_date,
        old.announcements, old.announcements_expire, 
        old.url, old.template_id,
        old.stock_status,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address
        );
	return new;
end;' language 'plpgsql';

create trigger ec_products_audit_tr
after update or delete on ec_products
for each row execute procedure ec_products_audit_tr ();


-- people who bought product_id also bought products 0 through
-- 4, where product_0 is the most frequently purchased, 1 is next,
-- etc.
create table ec_product_purchase_comb (
        product_id      integer not null primary key references ec_products,
        product_0       integer references ec_products,
        product_1       integer references ec_products,
        product_2       integer references ec_products,
        product_3       integer references ec_products,
        product_4       integer references ec_products
);

create index ec_product_purchase_comb_idx0 on ec_product_purchase_comb(product_0);
create index ec_product_purchase_comb_idx1 on ec_product_purchase_comb(product_1);
create index ec_product_purchase_comb_idx2 on ec_product_purchase_comb(product_2);
create index ec_product_purchase_comb_idx3 on ec_product_purchase_comb(product_3);
create index ec_product_purchase_comb_idx4 on ec_product_purchase_comb(product_4);

create sequence ec_sale_price_id_seq start 1;
create view ec_sale_price_id_sequence as select nextval('ec_sale_price_id_seq') as nextval;

create table ec_sale_prices (
        sale_price_id           integer not null primary key,
        product_id              integer not null references ec_products,
        sale_price              numeric,
        sale_begins             timestamptz not null,
        sale_ends               timestamptz not null,
        -- like Introductory Price or Sale Price or Special Offer
        sale_name               varchar(30),
        -- if non-null, the user has to know this code to get the sale price
        offer_code              varchar(20),
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null
);

create index ec_sale_prices_by_product_idx on ec_sale_prices(product_id);

create view ec_sale_prices_current
as
select * from ec_sale_prices
where now() >= sale_begins
and now() <= sale_ends;


create table ec_sale_prices_audit (
        sale_price_id           integer,
        product_id              integer,
        sale_price              numeric,
        sale_begins             timestamptz,
        sale_ends               timestamptz,
        sale_name               varchar(30),
        offer_code              varchar(20),
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f'
);


create function ec_sale_prices_audit_tr ()
returns opaque as '
begin
        insert into ec_sale_prices_audit (
        sale_price_id, product_id, sale_price,
        sale_begins, sale_ends, sale_name, offer_code,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.sale_price_id, old.product_id, old.sale_price,
        old.sale_begins, old.sale_ends, old.sale_name, old.offer_code,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address
        );
	return new;
end;' language 'plpgsql';

create trigger ec_sale_prices_audit_tr
after update or delete on ec_sale_prices
for each row execute procedure ec_sale_prices_audit_tr ();


create table ec_product_series_map (
        -- this is the product_id of a product that happens to be
        -- a series
        series_id               integer not null references ec_products,
        -- this is the product_id of a product that is one of the
        -- components of the above series
        component_id            integer not null references ec_products,
        primary key (series_id, component_id),
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null
);

create index ec_product_series_map_idx2 on ec_product_series_map(component_id);

create table ec_product_series_map_audit (
        series_id               integer,
        component_id            integer,
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f'
);


create function ec_product_series_map_audit_tr ()
returns opaque as '
begin
        insert into ec_product_series_map_audit (
        series_id, component_id,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.series_id, old.component_id,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address      
        );
	return new;
end;' language 'plpgsql';

create trigger ec_product_series_map_audit_tr
after update or delete on ec_product_series_map
for each row execute procedure ec_product_series_map_audit_tr ();


create sequence ec_address_id_seq start 1; 
create view ec_address_id_sequence as select nextval('ec_address_id_seq') as nextval;

create table ec_addresses (
        address_id      integer not null primary key,
        user_id         integer not null references users,
        address_type    varchar(20) not null,   -- e.g., billing
        attn            varchar(100),
        line1           varchar(100),
        line2           varchar(100),
        city            varchar(100),
        -- state
        -- Jerry, we'll need to creat the states table as part of this
        usps_abbrev     char(2) references us_states(abbrev),
        -- big enough to hold zip+4 with dash
        zip_code        varchar(10),
        phone           varchar(30),
        -- for international addresses
        -- Jerry, same for country_codes
        country_code    char(2) references countries(iso),
        -- this can be the province or region for an international address
        full_state_name varchar(30),
        -- D for day, E for evening
        phone_time      varchar(10)
);

create index ec_addresses_by_user_idx on ec_addresses (user_id);

create sequence ec_creditcard_id_seq start 1;
create view ec_creditcard_id_sequence as select nextval('ec_creditcard_id_seq') as nextval;

create table ec_creditcards (
        creditcard_id           integer not null primary key,
        user_id                 integer not null references users,
        -- Some credit card gateways do not ask for this but we'll store it anyway
        creditcard_type         char(1),
        -- no spaces; always 16 digits (oops; except for AMEX, which is 15)
        -- depending on admin settings, after we get success from the credit card gateway, 
        -- we may bash this to NULL
        creditcard_number       varchar(16),
        -- just the last four digits for subsequent UI
        creditcard_last_four    char(4),
        -- ##/## 
        creditcard_expire       char(5),
	billing_address 	integer references ec_addresses(address_id),
        -- if it ever failed (conclusively), set this to 't' so we
        -- won't give them the option of using it again
        failed_p                boolean default 'f'
);

create index ec_creditcards_by_user_idx on ec_creditcards (user_id);

create sequence ec_user_class_id_seq start 1;
create view ec_user_class_id_sequence as select nextval('ec_user_class_id_seq') as nextval;

create table ec_user_classes (
        user_class_id           integer not null primary key,
        -- human-readable
        user_class_name         varchar(200), -- e.g., student
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null
);

create table ec_user_classes_audit (
        user_class_id           integer,
        user_class_name         varchar(200), -- e.g., student
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f'
);

create function ec_user_classes_audit_tr ()
returns opaque as '
begin
        insert into ec_user_classes_audit (
        user_class_id, user_class_name,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.user_class_id, old.user_class_name,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address      
        );
	return new;
end;' language 'plpgsql';

create trigger ec_user_classes_audit_tr
after update or delete on ec_user_classes
for each row execute procedure ec_user_classes_audit_tr ();


create table ec_product_user_class_prices (
        product_id              integer not null references ec_products,
        user_class_id           integer not null references ec_user_classes,
        price                   numeric,
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null,
        primary key (product_id, user_class_id)
);

create index ec_product_user_class_idx on ec_product_user_class_prices(user_class_id);

-- ec_product_user_class_prices_audit abbreviated as
-- ec_product_u_c_prices_audit
create table ec_product_u_c_prices_audit (
        product_id              integer,
        user_class_id           integer,
        price                   numeric,
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f'
);

create function ec_product_u_c_prices_audit_tr ()
returns opaque as '
begin
        insert into ec_product_u_c_prices_audit (
        product_id, user_class_id,
        price,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.product_id, old.user_class_id,
        old.price,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address      
        );
	return new;
end;' language 'plpgsql';

create trigger ec_product_u_c_prices_audit_tr
after update or delete on ec_product_user_class_prices
for each row execute procedure ec_product_u_c_prices_audit_tr ();


create sequence ec_recommendation_id_seq start 1;
create view ec_recommendation_id_sequence as select nextval('ec_recommendation_id_seq') as nextval;

create table ec_product_recommendations (
        recommendation_id       integer not null primary key,
        product_id              integer not null references ec_products,
        -- might be null if the product is recommended for everyone
        user_class_id           integer references ec_user_classes,
        -- html format
        recommendation_text     varchar(4000),
        active_p                boolean default 't',
        -- where it's displayed (top level if all three are blank):
        category_id             integer references ec_categories,
        subcategory_id          integer references ec_subcategories,
        subsubcategory_id       integer references ec_subsubcategories,
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null
);

create index ec_product_recommendation_idx on ec_product_recommendations(category_id);
create index ec_product_recommendation_idx2 on ec_product_recommendations(subcategory_id);
create index ec_product_recommendation_idx3 on ec_product_recommendations(subsubcategory_id);
create index ec_product_recommendation_idx4 on ec_product_recommendations(user_class_id);
create index ec_product_recommendation_idx5 on ec_product_recommendations(active_p);

create table ec_product_recommend_audit (
        recommendation_id       integer,
        product_id              integer,
        user_class_id           integer,
        recommendation_text     varchar(4000),
        active_p                boolean default 't',
        category_id             integer,
        subcategory_id          integer,
        subsubcategory_id       integer,
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f'
);

create function ec_product_recommend_audit_tr ()
returns opaque as '
begin
        insert into ec_product_recommend_audit (
        recommendation_id, product_id,
        user_class_id, recommendation_text,
        active_p, category_id,
        subcategory_id, subsubcategory_id,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.recommendation_id, old.product_id,
        old.user_class_id, old.recommendation_text,
        old.active_p, old.category_id,
        old.subcategory_id, old.subsubcategory_id,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address      
        );
	return new;
end;' language 'plpgsql';

create trigger ec_product_recommend_audit_tr
after update or delete on ec_product_recommendations
for each row execute procedure ec_product_recommend_audit_tr ();

create view ec_recommendations_cats_view as
select 
  recs.*,
  coalesce(cats.category_id,subs.category_id,subsubs.category_id) as the_category_id,
  coalesce(cats.category_name,subs.category_name,subsubs.category_name) as the_category_name, 
  coalesce(subs.subcategory_id,subsubs.subcategory_id) as the_subcategory_id,
  coalesce(subs.subcategory_name,subsubs.subcategory_name) as the_subcategory_name,
  subsubs.subsubcategory_id as the_subsubcategory_id,
  subsubs.subsubcategory_name as the_subsubcategory_name
from 
  ec_product_recommendations recs
      LEFT JOIN
  ec_categories cats using (category_id)
      LEFT JOIN
  ec_subcategories_augmented subs using (subcategory_id)
      LEFT JOIN
  ec_subsubcategories_augmented subsubs on (recs.subsubcategory_id = subsubs.subcategory_id);

-- ec_categories cats, 
-- ec_subcategories_augmented subs, 
-- ec_subsubcategories_augmented subsubs
-- where 
  -- recs.category_id = cats.category_id(+)
-- and
  -- recs.subcategory_id = subs.subcategory_id(+)
-- and 
  -- recs.subsubcategory_id = subsubs.subcategory_id(+);

-- one row per customer-user; all the extra info that the ecommerce
-- system needs

create table ec_user_class_user_map (
        user_id                 integer not null references users,
        user_class_id           integer not null references ec_user_classes,
                                    primary key (user_id, user_class_id),
        user_class_approved_p   boolean,
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null
);

create index ec_user_class_user_map_idx on ec_user_class_user_map (user_class_id);
create index ec_user_class_user_map_idx2 on ec_user_class_user_map (user_class_approved_p);

create table ec_user_class_user_map_audit (
        user_id                 integer,
        user_class_id           integer,
        user_class_approved_p   boolean,
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f'
);


create function ec_user_class_user_audit_tr ()
returns opaque as '
begin
        insert into ec_user_class_user_map_audit (
        user_id, user_class_id, user_class_approved_p,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.user_id, old.user_class_id, old.user_class_approved_p,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address      
        );
	return new;
end;' language 'plpgsql';

create trigger ec_user_class_user_audit_tr
after update or delete on ec_user_class_user_map
for each row execute procedure ec_user_class_user_audit_tr ();


-- this specifies that product_a links to product_b on the display page for product_a
create table ec_product_links (
        product_a               integer not null references ec_products,
        product_b               integer not null references ec_products,
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null,
        primary key (product_a, product_b)
);

create index ec_product_links_idx on ec_product_links (product_b);

create table ec_product_links_audit (
        product_a               integer,
        product_b               integer,
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f'
);

create function ec_product_links_audit_tr ()
returns opaque as '
begin
        insert into ec_product_links_audit (
        product_a, product_b,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.product_a, old.product_b,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address      
        );
	return new;
end;' language 'plpgsql';

create trigger ec_product_links_audit_tr
after update or delete on ec_product_links
for each row execute procedure ec_product_links_audit_tr ();

create sequence ec_product_comment_id_seq start 1;
create view ec_product_comment_id_sequence as select nextval('ec_product_comment_id_seq') as nextval;

-- comments made by users on the products
create table ec_product_comments (
        comment_id              integer not null primary key,
        product_id              integer not null references ec_products,
        user_id                 integer not null references users,
        user_comment            varchar(4000),
        one_line_summary        varchar(300),
        rating                  numeric,
        -- in some systems, the administrator will have to approve comments first
        approved_p              boolean,
        comment_date            timestamptz,
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null
);

create index ec_product_comments_idx on ec_product_comments(product_id);
create index ec_product_comments_idx2 on ec_product_comments(user_id);
create index ec_product_comments_idx3 on ec_product_comments(approved_p);

create table ec_product_comments_audit (
        comment_id              integer,
        product_id              integer,
        user_id                 integer,
        user_comment            varchar(4000),
        one_line_summary        varchar(300),
        rating                  numeric,
        approved_p              boolean,
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f'
);

create function ec_product_comments_audit_tr ()
returns opaque as '
begin
        insert into ec_product_comments_audit (
        comment_id, product_id, user_id,
        user_comment, one_line_summary, rating, approved_p,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.comment_id, old.product_id, old.user_id,
        old.user_comment, old.one_line_summary, old.rating, old.approved_p,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address      
        );
	return new;
end;' language 'plpgsql';

create trigger ec_product_comments_audit_tr
after update or delete on ec_product_comments
for each row execute procedure ec_product_comments_audit_tr ();


create sequence ec_product_review_id_seq start 1;
create view ec_product_review_id_sequence as select nextval('ec_product_review_id_seq') as nextval;

-- reviews made by professionals of the products
create table ec_product_reviews (
        review_id               integer not null primary key,
        product_id              integer not null references ec_products,
        author_name             varchar(100),
        publication             varchar(100),
        review_date             timestamptz,
        -- in HTML format
        review                  text,
        display_p               boolean,
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null
);

create index ec_product_reviews_idx on ec_product_reviews (product_id);
create index ec_product_reviews_idx2 on ec_product_reviews (display_p);

create table ec_product_reviews_audit (
        review_id               integer,
        product_id              integer,
        author_name             varchar(100),
        publication             varchar(100),
        review_date             timestamptz,
        -- in HTML format
        review                  text,
        display_p               boolean,
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f'
);

create function ec_product_reviews_audit_tr ()
returns opaque as '
begin
        insert into ec_product_reviews_audit (
        review_id, product_id,
        author_name, publication, review_date,
        review,
        display_p,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.review_id, old.product_id,
        old.author_name, old.publication, old.review_date,
        old.review, 
        old.display_p,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address      
        );
	return new;
end;' language 'plpgsql';

create trigger ec_product_reviews_audit_tr
after update or delete on ec_product_reviews
for each row execute procedure ec_product_reviews_audit_tr ();


-- a product can be in more than one category
create table ec_category_product_map (
        product_id              integer not null references ec_products,
        category_id             integer not null references ec_categories,
        publisher_favorite_p    boolean,
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null,
        primary key (product_id, category_id)
);

create index ec_category_product_map_idx on ec_category_product_map (category_id);
create index ec_category_product_map_idx2 on ec_category_product_map (publisher_favorite_p);

create table ec_category_product_map_audit (
        product_id              integer,
        category_id             integer,
        publisher_favorite_p    boolean,
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f'
);

-- ec_category_product_map_audit_tr abbreviated as
-- ec_cat_prod_map_audit_tr
create function ec_cat_prod_map_audit_tr ()
returns opaque as '
begin
        insert into ec_category_product_map_audit (
        product_id, category_id,
        publisher_favorite_p,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.product_id, old.category_id,
        old.publisher_favorite_p,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address              
        );
	return new;
end;' language 'plpgsql';

create trigger ec_cat_prod_map_audit_tr
after update or delete on ec_category_product_map
for each row execute procedure ec_cat_prod_map_audit_tr ();


create table ec_subcategory_product_map (
        product_id              integer not null references ec_products,
        subcategory_id          integer not null references ec_subcategories,
        publisher_favorite_p    boolean,
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null,
        primary key (product_id, subcategory_id)
);

create index ec_subcat_product_map_idx on ec_subcategory_product_map (subcategory_id);
create index ec_subcat_product_map_idx2 on ec_subcategory_product_map (publisher_favorite_p);

-- ec_subcategory_product_map_audit abbreviated as
create table ec_subcat_prod_map_audit (
        product_id              integer,
        subcategory_id          integer,
        publisher_favorite_p    boolean,
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f'
);

-- ec_subcat_prod_map_audit_tr
create function ec_subcat_prod_map_audit_tr ()
returns opaque as '
begin
        insert into ec_subcat_prod_map_audit (
        product_id, subcategory_id,
        publisher_favorite_p,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.product_id, old.subcategory_id,
        old.publisher_favorite_p,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address              
        );
	return new;
end;' language 'plpgsql';

create trigger ec_subcat_prod_map_audit_tr
after update or delete on ec_subcategory_product_map
for each row execute procedure ec_subcat_prod_map_audit_tr ();


create table ec_subsubcategory_product_map (
        product_id              integer not null references ec_products,
        subsubcategory_id       integer not null references ec_subsubcategories,
        publisher_favorite_p    boolean,
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null,
        primary key (product_id, subsubcategory_id)
);

create index ec_subsubcat_prod_map_idx on ec_subsubcategory_product_map (subsubcategory_id);
create index ec_subsubcat_prod_map_idx2 on ec_subsubcategory_product_map (publisher_favorite_p);

create table ec_subsubcat_prod_map_audit (
        product_id              integer,
        subsubcategory_id       integer,
        publisher_favorite_p    boolean,
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f'
);

create function ec_subsubcat_prod_map_audit_tr ()
returns opaque as '
begin
        insert into ec_subsubcat_prod_map_audit (
        product_id, subsubcategory_id,
        publisher_favorite_p,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.product_id, old.subsubcategory_id,
        old.publisher_favorite_p,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address              
        );
	return new;
end;' language 'plpgsql';

create trigger ec_subsubcat_prod_map_audit_tr
after update or delete on ec_subsubcategory_product_map
for each row execute procedure ec_subsubcat_prod_map_audit_tr ();

-- A template can have more than 1 category associated
-- with it, but a category can have at most one template.
-- When a product is added in a given category, its template
-- will default to the one associated with its category (if
-- the product is in more than 1 category, it'll get the
-- template associated with one of its categories), although
-- the admin can always associate a product with any category
-- they want.
create table ec_category_template_map (
        category_id             integer not null primary key references ec_categories,
        template_id             integer not null references ec_templates
);

create index ec_category_template_map_idx on ec_category_template_map (template_id);


-- I could in theory make some hairy system that lets them specify
-- what kind of form element each field will have, does 
-- error checking, etc., but I don't think it's necessary since it's 
-- just the site administrator using it.  So here's a very simple
-- table to store the custom product fields:
create table ec_custom_product_fields (
        field_identifier        varchar(100) not null primary key,
        field_name              varchar(100),
        default_value           varchar(100),
        -- column type for oracle (i.e. text, varchar(50), integer, ...)
        column_type             varchar(100),
        creation_date           timestamptz,
        active_p                boolean default 't',
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null
);

create table ec_custom_product_fields_audit (
        field_identifier        varchar(100),
        field_name              varchar(100),
        default_value           varchar(100),
        column_type             varchar(100),
        creation_date           timestamptz,
        active_p                boolean default 't',
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f'
);

create function ec_custom_prod_fields_audit_tr ()
returns opaque as '
begin
        insert into ec_custom_product_fields_audit (
        field_identifier, field_name,
        default_value, column_type,
        creation_date, active_p,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.field_identifier, old.field_name,
        old.default_value, old.column_type,
        old.creation_date, old.active_p,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address              
        );
	return new;
end;' language 'plpgsql';

create trigger ec_custom_prod_fields_audit_tr
after update or delete on ec_custom_product_fields
for each row execute procedure ec_custom_prod_fields_audit_tr ();

-- more columns are added to this table (by Tcl scripts) when the 
-- administrator adds custom product fields
-- the columns in this table have the name of the field_identifiers
-- in ec_custom_product_fields
-- this table stores the values
create table ec_custom_product_field_values (
        product_id              integer not null primary key references ec_products,
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null
);

create table ec_custom_p_field_values_audit (
        product_id              integer,
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f'
);

create function ec_custom_p_f_values_audit_tr ()
returns opaque as '
begin
        insert into ec_custom_p_field_values_audit (
        product_id,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.product_id,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address      
        );
	return new;
end;' language 'plpgsql';

create trigger ec_custom_p_f_values_audit_tr
after update or delete on ec_custom_product_field_values
for each row execute procedure ec_custom_p_f_values_audit_tr();


create sequence ec_user_session_seq;
create view ec_user_session_sequence as select nextval('ec_user_session_seq') as nextval;

create table ec_user_sessions (
        user_session_id         integer not null constraint ec_session_id_pk primary key,
        -- often will not be known
        user_id                 integer references users,
        ip_address              varchar(20) not null,
        start_time              timestamptz,
        http_user_agent         varchar(4000)
);

create index ec_user_sessions_idx on ec_user_sessions(user_id);

create table ec_user_session_info (
        user_session_id         integer not null references ec_user_sessions,
        product_id              integer references ec_products,
        category_id             integer references ec_categories,
        search_text             varchar(200)
);

create index ec_user_session_info_idx  on ec_user_session_info (user_session_id);
create index ec_user_session_info_idx2 on ec_user_session_info (product_id);
create index ec_user_session_info_idx3 on ec_user_session_info (category_id);

-- If a user comes to product.tcl with an offer_code in the url,
-- I'm going to shove it into this table and then check this
-- table each time I try to determine the price for the users'
-- products.  The alternative is to store the offer_codes in a
-- cookie and look at that each time I try to determine the price
-- for a product.  But I think this will be a little faster.

create table ec_user_session_offer_codes (
        user_session_id         integer not null references ec_user_sessions,
        product_id              integer not null references ec_products,
        offer_code              varchar(20) not null,
        primary key (user_session_id, product_id)
);

-- create some indices
create index ec_u_s_offer_codes_by_u_s_id on ec_user_session_offer_codes(user_session_id);
create index ec_u_s_offer_codes_by_p_id on ec_user_session_offer_codes(product_id);

create sequence ec_order_id_seq start 3000000;
create view ec_order_id_sequence as select nextval('ec_order_id_seq') as nextval;

create table ec_orders (
        order_id        	integer not null primary key,
        -- can be null, until they've checked out or saved their basket
        user_id			integer  references users,
        user_session_id		integer references ec_user_sessions,
        order_state		varchar(50) default 'in_basket' not null,
        tax_exempt_p            boolean default 'f',
        shipping_method		varchar(20),    -- express or standard or pickup or 'no shipping'
        shipping_address        integer references ec_addresses(address_id),
        -- store credit card info in a different table
        creditcard_id		integer references ec_creditcards(creditcard_id),
        -- information recorded upon FSM state changes
        -- we need this to figure out if order is stale
        -- and should be offered up for removal
        in_basket_date          timestamptz,
        confirmed_date          timestamptz,
        authorized_date         timestamptz,
        voided_date             timestamptz,
        expired_date            timestamptz,
        -- base shipping, which is added to the amount charged for each item
        shipping_charged        numeric,
        shipping_refunded       numeric,
        shipping_tax_charged    numeric,
        shipping_tax_refunded   numeric,
        -- entered by customer service
        cs_comments             varchar(4000),
        reason_for_void         varchar(4000),
        voided_by               integer references users,
        -- if the user chooses to save their shopping cart
        saved_p                 boolean
        check (user_id is not null or user_session_id is not null)
);

create index ec_orders_by_user_idx on ec_orders (user_id);
create index ec_orders_by_user_sess_idx on ec_orders (user_session_id);
create index ec_orders_by_credit_idx on ec_orders (creditcard_id);
create index ec_orders_by_addr_idx on ec_orders (shipping_address);
create index ec_orders_by_conf_idx on ec_orders (confirmed_date);
create index ec_orders_by_state_idx on ec_orders (order_state);

-- note that an order could essentially become uninteresting for financial
-- accounting if all the items underneath it are individually voided or returned

create view ec_orders_reportable
as 
select * 
from ec_orders 
where order_state <> 'in_basket'
and order_state <> 'void';

-- orders that have items which still need to be shipped
create view ec_orders_shippable
as
select *
from ec_orders
where order_state in ('authorized','partially_fulfilled');


-- this is needed because orders might be only partially shipped
create sequence ec_shipment_id_seq;
create view ec_shipment_id_sequence as select nextval('ec_shipment_id_seq') as nextval;

create table ec_shipments (
        shipment_id             integer not null primary key,
        order_id                integer not null references ec_orders,
        -- usually, but not necessarily, the same as the shipping_address
        -- in ec_orders because a customer may change their address between
        -- shipments.
        -- a trigger fills address_id in automatically if it's null
        address_id              integer references ec_addresses,
        shipment_date           timestamptz not null,
        expected_arrival_date   timestamptz,
        carrier                 varchar(50),    -- e.g., 'fedex'
        tracking_number         varchar(24),
        -- only if we get confirmation from carrier that the goods
        -- arrived on a specific date
        actual_arrival_date     timestamptz,
        -- arbitrary info from carrier, e.g., 'Joe Smith signed for it'
        actual_arrival_detail   varchar(4000),
        -- for things that aren't really shipped like services
        shippable_p             boolean default 't',
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20)
);

create index ec_shipments_by_order_id on ec_shipments(order_id);
create index ec_shipments_by_shipment_date on ec_shipments(shipment_date);

-- fills address_id into ec_shipments if it's missing
-- (using the shipping_address associated with the order)
create function ec_shipment_address_update_tr ()
returns opaque as '
declare
        v_address_id            ec_addresses.address_id%TYPE;
begin
        select into v_address_id shipping_address 
	from ec_orders where order_id=new.order_id;
        IF new.address_id is null THEN
                new.address_id := v_address_id;
        END IF;
	return new;
end;' language 'plpgsql';

create trigger ec_shipment_address_update_tr
before insert on ec_shipments
for each row execute procedure ec_shipment_address_update_tr ();

create table ec_shipments_audit (
        shipment_id             integer,
        order_id                integer,
        address_id              integer,
        shipment_date           timestamptz,
        expected_arrival_date   timestamptz,
        carrier                 varchar(50),
        tracking_number         varchar(24),
        actual_arrival_date     timestamptz,
        actual_arrival_detail   varchar(4000),
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f'
);

create function ec_shipments_audit_tr ()
returns opaque as '
begin
        insert into ec_shipments_audit (
        shipment_id, order_id, address_id,
        shipment_date, 
        expected_arrival_date,
        carrier, tracking_number,
        actual_arrival_date, actual_arrival_detail,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.shipment_id, old.order_id, old.address_id,
        old.shipment_date,
        old.expected_arrival_date,
        old.carrier, old.tracking_number,
        old.actual_arrival_date, old.actual_arrival_detail,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address      
        );
	return new;
end;' language 'plpgsql';

create trigger ec_shipments_audit_tr
after update or delete on ec_shipments
for each row execute procedure ec_shipments_audit_tr ();

create sequence refund_id_seq;
create view refund_id_sequence as select nextval('refund_id_seq') as nextval;

create table ec_refunds (
        refund_id       integer not null primary key,
        order_id        integer not null references ec_orders,
        -- not really necessary because it's in ec_financial_transactions
        refund_amount   numeric not null,
        refund_date     timestamptz not null,
        refunded_by     integer not null references users,
        refund_reasons  varchar(4000)
);

create index ec_refunds_by_order_idx on ec_refunds (order_id);

-- these are the items that make up each order
create sequence ec_item_id_seq start 1; 
create view ec_item_id_sequence as select nextval('ec_item_id_seq') as nextval;

create table ec_items (
        item_id         integer not null primary key,
        order_id        integer not null references ec_orders,
        product_id      integer not null references ec_products,
        color_choice    varchar(4000),
        size_choice     varchar(4000),
        style_choice    varchar(4000),
        shipment_id     integer references ec_shipments,
        -- this is the date that user put this item into their shopping basket
        in_cart_date    timestamptz,
        voided_date     timestamptz,
        voided_by       integer references users,
        expired_date    timestamptz,
        item_state      varchar(50) default 'in_basket',
        -- NULL if not received back
        received_back_date      timestamptz,
        -- columns for reporting (e.g., what was done, what was made)
        price_charged           numeric,
        price_refunded          numeric,
        shipping_charged        numeric,
        shipping_refunded       numeric,
        price_tax_charged       numeric,
        price_tax_refunded      numeric,
        shipping_tax_charged    numeric,
        shipping_tax_refunded   numeric,
        -- like Our Price or Sale Price or Introductory Price
        price_name              varchar(30),
        -- did we go through a merchant-initiated refund?
        refund_id               integer references ec_refunds,
        -- comments entered by customer service (CS)
        cs_comments             varchar(4000)
);

create index ec_items_by_product on ec_items(product_id);
create index ec_items_by_order on ec_items(order_id);
create index ec_items_by_shipment on ec_items(shipment_id);

create view ec_items_reportable 
as 
select * 
from ec_items
where item_state in ('to_be_shipped', 'shipped', 'arrived');

create view ec_items_refundable
as
select *
from ec_items
where item_state in ('shipped','arrived')
and refund_id is null;

create view ec_items_shippable
as
select *
from ec_items
where item_state in ('to_be_shipped');

-- This view displays:
-- order_id
-- shipment_date
-- bal_price_charged sum(price_charged - price_refunded) for all items in the shipment
-- bal_shipping_charged
-- bal_tax_charged
-- The purpose: payment is recognized when an item ships so this sums the various
-- parts of payment (price, shipping, tax) for all the items in each shipment

-- gilbertw - there is a note in OpenACS 3.2.5 from DRB:
-- DRB: this view is never used and blows out Postgres, which thinks
-- it's too large even with a block size of (gulp) 16384!
-- gilbertw - this view is used now. 

create view ec_items_money_view
as
select i.shipment_id, i.order_id, s.shipment_date, coalesce(sum(i.price_charged),0) - coalesce(sum(i.price_refunded),0) as bal_price_charged,
coalesce(sum(i.shipping_charged),0) - coalesce(sum(i.shipping_refunded),0) as bal_shipping_charged,
coalesce(sum(i.price_tax_charged),0) - coalesce(sum(i.price_tax_refunded),0) + coalesce(sum(i.shipping_tax_charged),0)
  - coalesce(sum(i.shipping_tax_refunded),0) as bal_tax_charged
from ec_items i, ec_shipments s
where i.shipment_id=s.shipment_id
and i.item_state <> 'void'
group by i.order_id, i.shipment_id, s.shipment_date;

-- a set of triggers to update order_state based on what happens
-- to the items in the order
-- partially_fulfilled: some but not all non-void items have shipped
-- fulfilled: all non-void items have shipped
-- returned: all non-void items received_back
-- void: all items void
-- We're not interested in partial returns.

-- this is hellish because you can't select a count of the items
-- in a given item_state from ec_items when you're updating ec_items,
-- so we have to do a horrid "trio" (temporary table, row level trigger,
-- system level trigger) as discussed in
-- http://photo.net/doc/site-wide-search.html (we use a temporary
-- table instead of a package because they're better)

-- I. temporary table to hold the order_ids that have to have their
-- state updated as a result of the item_state changes

-- gilbertw - this table is not needed in PostgreSQL
--create global temporary table ec_state_change_order_ids (
--        order_id        integer
--);

-- gilbertw - this trigger is not needed
-- II. row-level trigger which updates ec_state_change_order_ids 
-- so we know which rows to update in ec_orders
-- create function ec_order_state_before_tr ()
-- returns opaque as '
-- begin
--         insert into ec_state_change_order_ids (order_id) values (new.order_id);
-- 	return new;
-- end;' language 'plpgsql';

-- create trigger ec_order_state_before_tr
-- before update on ec_items
-- for each row execute procedure ec_order_state_before_tr ();

-- III. System level trigger to update all the rows that were changed
-- in the before trigger.

-- gilbertw - I took the trigger procedure from OpenACS 3.2.5.
create function ec_order_state_after_tr ()
returns opaque as '
declare
        -- v_order_id              integer;
        n_items                 integer;
        n_shipped_items         integer;
        n_received_back_items   integer;
        n_void_items            integer;
        n_nonvoid_items         integer;

begin
	select count(*) into n_items from ec_items where order_id=NEW.order_id;
        select count(*) into n_shipped_items from ec_items 
	    where order_id=NEW.order_id
	    and item_state=''shipped'' or item_state=''arrived'';
        select count(*) into n_received_back_items
	    from ec_items where order_id=NEW.order_id
	    and item_state=''received_back'';
        select count(*) into n_void_items from ec_items 
	    where order_id=NEW.order_id and item_state=''void'';

        IF n_items = n_void_items THEN
            update ec_orders set order_state=''void'', voided_date=now()
		where order_id=NEW.order_id;
        ELSE
            n_nonvoid_items := n_items - n_void_items;
            IF n_nonvoid_items = n_received_back_items THEN
                update ec_orders set order_state=''returned'' 
		    where order_id=NEW.order_id;
            ELSE 
		IF n_nonvoid_items = n_received_back_items + n_shipped_items THEN
		    update ec_orders set order_state=''fulfilled'' 
			where order_id=NEW.order_id;
            	ELSE
		    IF n_shipped_items >= 1 or n_received_back_items >=1 THEN
			update ec_orders set order_state=''partially_fulfilled''
			    where order_id=NEW.order_id;
            	    END IF;
        	END IF;
	    END IF;
	END IF;
	return new;
end;' language 'plpgsql';

create trigger ec_order_state_after_tr 
after update on ec_items 
for each row execute procedure ec_order_state_after_tr ();

-- this is a 1-row table
-- it contains all settings that the admin can change from the admin pages
-- most of the configuration is done using the parameters .ini file
-- wtem@olywa.net 03-10-2001
-- the following two tables probably need an additional column to support subsites
-- in which case it will have multiple rows, one for each instance of ecommerce
-- since these are really parameters for the instance of ecommerce, 
-- it might be better to move them to ad_parameters
create table ec_admin_settings (
        -- this is here just so that the insert statement (a page or
        -- so down) can't be executed twice
        admin_setting_id                integer not null primary key,   
        -- the following columns are related to shipping costs
        base_shipping_cost              numeric,
        default_shipping_per_item       numeric,
        weight_shipping_cost            numeric,
        add_exp_base_shipping_cost      numeric,
        add_exp_amount_per_item         numeric,
        add_exp_amount_by_weight        numeric,
        -- default template to use if the product isn't assigned to one
        -- (until the admin changes it, it will be 1, which will be
        -- the preloaded template)
        default_template        	integer default 1 not null 
					    references ec_templates,
        last_modified           	timestamptz not null,
        last_modifying_user     	integer not null references users,
        modified_ip_address     	varchar(20) not null
);

create table ec_admin_settings_audit (
        admin_setting_id                integer,
        base_shipping_cost              numeric,
        default_shipping_per_item       numeric,
        weight_shipping_cost            numeric,
        add_exp_base_shipping_cost      numeric,
        add_exp_amount_per_item         numeric,
        add_exp_amount_by_weight        numeric,
        default_template        	integer,
        last_modified           	timestamptz,
        last_modifying_user     	integer,
        modified_ip_address     	varchar(20),
        delete_p                	boolean default 'f'
);

create function ec_admin_settings_audit_tr ()
returns opaque as '
begin
        insert into ec_admin_settings_audit (
        admin_setting_id, base_shipping_cost, default_shipping_per_item,
        weight_shipping_cost, add_exp_base_shipping_cost,
        add_exp_amount_per_item, add_exp_amount_by_weight,
        default_template,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.admin_setting_id, old.base_shipping_cost, 
	old.default_shipping_per_item,
        old.weight_shipping_cost, old.add_exp_base_shipping_cost,
        old.add_exp_amount_per_item, old.add_exp_amount_by_weight,
        old.default_template,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address      
        );
	return new;
end;' language 'plpgsql';

create trigger ec_admin_settings_audit_tr
after update or delete on ec_admin_settings
for each row execute procedure ec_admin_settings_audit_tr ();

-- this is where the ec_amdin_settings insert was

-- this is populated by the rules the administrator sets in packages/ecommerce/www/admin]/sales-tax.tcl
create table ec_sales_tax_by_state (
       -- Jerry
        usps_abbrev             char(2) not null primary key references us_states(abbrev),
        -- this a decimal number equal to the percentage tax divided by 100
        tax_rate                numeric not null,
        -- charge tax on shipping?
        shipping_p              boolean not null,
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null
);

create table ec_sales_tax_by_state_audit (
        usps_abbrev             char(2),
        tax_rate                numeric,
        shipping_p              boolean,
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f'
);


-- Jerry - I removed usps_abbrev and/or state here
create function ec_sales_tax_by_state_audit_tr ()
returns opaque as '
begin
        insert into ec_sales_tax_by_state_audit (
        usps_abbrev, tax_rate,
        shipping_p,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.usps_abbrev, old.tax_rate,
        old.shipping_p,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address              
        );
	return new;
end;' language 'plpgsql';

create trigger ec_sales_tax_by_state_audit_tr
after update or delete on ec_sales_tax_by_state
for each row execute procedure ec_sales_tax_by_state_audit_tr ();

-- these tables are used if MultipleRetailersPerProductP is 1 in the
-- parameters .ini file

create sequence ec_retailer_seq start 1;
create view ec_retailer_sequence as select nextval('ec_retailer_seq') as nextval;

create table ec_retailers (
        retailer_id             integer not null primary key,
        retailer_name           varchar(300),
        primary_contact_name    varchar(100),
        secondary_contact_name  varchar(100),
        primary_contact_info    varchar(4000),
        secondary_contact_info  varchar(4000),
        line1                   varchar(100),
        line2                   varchar(100),
        city                    varchar(100),
        -- state
        -- Jerry
        usps_abbrev     	char(2) references us_states(abbrev),
        -- big enough to hold zip+4 with dash
        zip_code                varchar(10),
        phone                   varchar(30),
        fax                     varchar(30),
        -- for international addresses
        -- Jerry
        country_code            char(2) references countries(iso),
        --national, local, international
        reach                   varchar(15) check (reach in ('national','local','international','regional','web')),
        url                     varchar(200),
        -- space-separated list of states in which tax must be collected
        nexus_states            varchar(200),
        financing_policy        varchar(4000),
        return_policy           varchar(4000),
        price_guarantee_policy  varchar(4000),
        delivery_policy         varchar(4000),
        installation_policy     varchar(4000),
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null
);

create table ec_retailers_audit (
        retailer_id             integer,
        retailer_name           varchar(300),
        primary_contact_name    varchar(100),
        secondary_contact_name  varchar(100),
        primary_contact_info    varchar(4000),
        secondary_contact_info  varchar(4000),
        line1           	varchar(100),
        line2           	varchar(100),
        city            	varchar(100),
        usps_abbrev     	char(2),
        zip_code        	varchar(10),
        phone           	varchar(30),
        fax             	varchar(30),
        country_code    	char(2),
        reach           	varchar(15) check (reach in ('national','local','international','regional','web')),
        url             	varchar(200),
        nexus_states    	varchar(200),
        financing_policy        varchar(4000),
        return_policy           varchar(4000),
        price_guarantee_policy  varchar(4000),
        delivery_policy         varchar(4000),
        installation_policy     varchar(4000),
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f'
);

-- Jerry - I removed usps_abbrev and/or state here
create function ec_retailers_audit_tr ()
returns opaque as '
begin
        insert into ec_retailers_audit (
        retailer_id, retailer_name,
        primary_contact_name, secondary_contact_name,
        primary_contact_info, secondary_contact_info,
        line1, line2,
        city, usps_abbrev,
        zip_code, phone,
        fax, country_code,
        reach, url,
        nexus_states, financing_policy,
        return_policy, price_guarantee_policy,
        delivery_policy, installation_policy,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.retailer_id, old.retailer_name,
        old.primary_contact_name, old.secondary_contact_name,
        old.primary_contact_info, old.secondary_contact_info,
        old.line1, old.line2,
        old.city, old.usps_abbrev,
        old.zip_code, old.phone,
        old.fax, old.country_code,
        old.reach, old.url,
        old.nexus_states, old.financing_policy,
        old.return_policy, old.price_guarantee_policy,
        old.delivery_policy, old.installation_policy,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address      
        );
	return new;
end;' language 'plpgsql';

create trigger ec_retailers_audit_tr
after update or delete on ec_retailers
for each row execute procedure ec_retailers_audit_tr ();

create sequence ec_retailer_location_seq start 1;
create view ec_retailer_location_sequence as select nextval('ec_retailer_location_seq') as nextval;

create table ec_retailer_locations (
        retailer_location_id    integer not null primary key,
        retailer_id             integer not null references ec_retailers,
        location_name           varchar(300),
        primary_contact_name    varchar(100),
        secondary_contact_name  varchar(100),
        primary_contact_info    varchar(4000),
        secondary_contact_info  varchar(4000),
        line1                   varchar(100),
        line2                   varchar(100),
        city                    varchar(100),
        -- state
        -- Jerry
	-- usps_abbrev reinstated by wtem@olywa.net
        usps_abbrev     	char(2) references us_states(abbrev),
        -- big enough 0to hold zip+4 with dash
        zip_code                varchar(10),
        phone                   varchar(30),
        fax                     varchar(30),
        -- for international addresses
        -- Jerry
	-- country_code reinstated by wtem@olywa.net
        country_code            char(2) references countries(iso),
        url                     varchar(200),
        financing_policy        varchar(4000),
        return_policy           varchar(4000),
        price_guarantee_policy  varchar(4000),
        delivery_policy         varchar(4000),
        installation_policy     varchar(4000),
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null
);

create table ec_retailer_locations_audit (
        retailer_location_id    integer,
        retailer_id             integer,
        location_name           varchar(300),
        primary_contact_name    varchar(100),
        secondary_contact_name  varchar(100),
        primary_contact_info    varchar(4000),
        secondary_contact_info  varchar(4000),
        line1           	varchar(100),
        line2           	varchar(100),
        city            	varchar(100),
        usps_abbrev     	char(2),
        zip_code        	varchar(10),
        phone           	varchar(30),
        fax             	varchar(30),
        country_code    	char(2),
        url             	varchar(200),
        financing_policy        varchar(4000),
        return_policy           varchar(4000),
        price_guarantee_policy  varchar(4000),
        delivery_policy         varchar(4000),
        installation_policy     varchar(4000),
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f'
);


-- Jerry - I removed usps_abbrev and/or state here
create function ec_retailer_locations_audit_tr ()
returns opaque as '
begin
        insert into ec_retailer_locations_audit (
        retailer_location_id, retailer_id, location_name,
        primary_contact_name, secondary_contact_name,
        primary_contact_info, secondary_contact_info,
        line1, line2,
        city, usps_abbrev,
        zip_code, phone,
        fax, country_code,
        url, financing_policy,
        return_policy, price_guarantee_policy,
        delivery_policy, installation_policy,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.retailer_location_id,
        old.retailer_id, old.location_name,
        old.primary_contact_name, old.secondary_contact_name,
        old.primary_contact_info, old.secondary_contact_info,
        old.line1, old.line2,
        old.city, old.usps_abbrev,
        old.zip_code, old.phone,
        old.fax, old.country_code,
        old.url, old.financing_policy,
        old.return_policy, old.price_guarantee_policy,
        old.delivery_policy, old.installation_policy,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address
        );
	return new;
end;' language 'plpgsql';

create trigger ec_retailer_locations_audit_tr
after update or delete on ec_retailer_locations
for each row execute procedure ec_retailer_locations_audit_tr ();


create sequence ec_offer_seq start 1;
create view ec_offer_sequence as select nextval('ec_offer_seq') as nextval;

create table ec_offers (
        offer_id                integer not null primary key,
        product_id              integer not null references ec_products,
        retailer_location_id    integer not null references ec_retailer_locations,
        store_sku               integer,
        retailer_premiums       varchar(500),
        price                   numeric not null,
        shipping                numeric,
        shipping_unavailable_p  boolean,
        -- o = out of stock, q = ships quickly, m = ships
        -- moderately quickly, s = ships slowly, i = in stock
        -- with no message about the speed of the shipment (shipping
        -- messages are in parameters .ini file)
        stock_status            char(1) check (stock_status in ('o','q','m','s','i')),
        special_offer_p         boolean,
        special_offer_html      varchar(500),
        offer_begins            timestamptz not null,
        offer_ends              timestamptz not null,
        deleted_p               boolean default 'f',
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null
);

create view ec_offers_current
as
select * from ec_offers
where deleted_p='f'
and now() >= offer_begins
and now() <= offer_ends;


create table ec_offers_audit (
        offer_id                integer,
        product_id              integer,
        retailer_location_id    integer,
        store_sku               integer,
        retailer_premiums       varchar(500),
        price                   numeric,
        shipping                numeric,
        shipping_unavailable_p  boolean,
        stock_status            char(1) check (stock_status in ('o','q','m','s','i')),
        special_offer_p         boolean,
        special_offer_html      varchar(500),
        offer_begins            timestamptz,
        offer_ends              timestamptz,
        deleted_p               boolean default 'f',
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        -- This differs from the deleted_p column!
        -- deleted_p refers to the user request to stop offering
        -- delete_p indicates the row has been deleted from the main offers table
        delete_p                boolean default 'f'
);


create function ec_offers_audit_tr ()
returns opaque as '
begin
        insert into ec_offers_audit (
        offer_id,
        product_id, retailer_location_id,
        store_sku, retailer_premiums,
        price, shipping,
        shipping_unavailable_p, stock_status,
        special_offer_p, special_offer_html,
        offer_begins, offer_ends,
        deleted_p,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.offer_id,
        old.product_id, old.retailer_location_id,
        old.store_sku, old.retailer_premiums,
        old.price, old.shipping,
        old.shipping_unavailable_p, old.stock_status,
        old.special_offer_p, old.special_offer_html,
        old.offer_begins, old.offer_ends,
        old.deleted_p,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address
        );
	return new;
end;' language 'plpgsql';

create trigger ec_offers_audit_tr
after update or delete on ec_offers
for each row execute procedure ec_offers_audit_tr ();

-- Gift certificate stuff ----
------------------------------

create sequence ec_gift_cert_id_seq start 1000000;
create view ec_gift_cert_id_sequence as select nextval('ec_gift_cert_id_seq') as nextval;

create table ec_gift_certificates (
        gift_certificate_id     integer primary key,
        gift_certificate_state  varchar(50) not null,
        amount                  numeric not null,
        -- a trigger will update this to f if the
        -- entire amount is used up (to speed up
        -- queries)
        amount_remaining_p      boolean default 't',
        issue_date              timestamptz,
        authorized_date         timestamptz,
        claimed_date            timestamptz,
        -- customer service rep who issued it
        issued_by               integer references users,
        -- customer who purchased it
        purchased_by            integer references users,
        expires                 timestamptz,
        user_id                 integer references users,
        -- if it's unclaimed, claim_check will be filled in,
        -- and user_id won't be filled in
        -- claim check should be unique (one way to do this
        -- is to always begin it with "$gift_certificate_id-")
        claim_check             varchar(50),
        certificate_message     varchar(200),
        certificate_to          varchar(100),
        certificate_from        varchar(100),
        recipient_email         varchar(100),
        voided_date             timestamptz,
        voided_by               integer references users,
        reason_for_void         varchar(4000),
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null,
        check (user_id is not null or claim_check is not null)
);

create index ec_gc_by_state on ec_gift_certificates(gift_certificate_state);
create index ec_gc_by_amount_remaining on ec_gift_certificates(amount_remaining_p);
create index ec_gc_by_user on ec_gift_certificates(user_id);
create index ec_gc_by_claim_check on ec_gift_certificates(claim_check);

-- note: there's a trigger in ecommerce-plsql.sql which updates amount_remaining_p
-- when a gift certificate is used

-- note2: there's a 1-1 correspondence between user-purchased gift certificates
-- and financial transactions.  ec_financial_transactions stores the corresponding
-- gift_certificate_id.

create view ec_gift_certificates_approved
as 
select * 
from ec_gift_certificates
where gift_certificate_state in ('authorized');

create view ec_gift_certificates_purchased
as
select *
from ec_gift_certificates
where gift_certificate_state in ('authorized');

create view ec_gift_certificates_issued
as
select *
from ec_gift_certificates
where gift_certificate_state in ('authorized')
  and issued_by is not null;


create table ec_gift_certificates_audit (
        gift_certificate_id     integer,
        gift_certificate_state  varchar(50),
        amount                  numeric,
        issue_date              timestamptz,
        authorized_date         timestamptz,
        issued_by               integer,
        purchased_by            integer,
        expires                 timestamptz,
        user_id                 integer,
        claim_check             varchar(50),
        certificate_message     varchar(200),
        certificate_to          varchar(100),
        certificate_from        varchar(100),
        recipient_email         varchar(100),
        voided_date             timestamptz,
        voided_by               integer,
        reason_for_void         varchar(4000),
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f' 
);


create function ec_gift_certificates_audit_tr ()
returns opaque as '
begin
        insert into ec_gift_certificates_audit (
        gift_certificate_id, amount,
        issue_date, authorized_date, issued_by, purchased_by, expires,
        user_id, claim_check, certificate_message,
        certificate_to, certificate_from,
        recipient_email, voided_date, voided_by, reason_for_void,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.gift_certificate_id, old.amount,
        old.issue_date, old.authorized_date, old.issued_by, old.purchased_by, old.expires,
        old.user_id, old.claim_check, old.certificate_message,
        old.certificate_to, old.certificate_from,
        old.recipient_email, old.voided_date, old.voided_by, old.reason_for_void,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address      
        );
	return new;
end;' language 'plpgsql';

create trigger ec_gift_certificates_audit_tr
after update or delete on ec_gift_certificates
for each row execute procedure ec_gift_certificates_audit_tr ();


create table ec_gift_certificate_usage (
        gift_certificate_id     integer not null references ec_gift_certificates,
        order_id                integer references ec_orders,
        amount_used             numeric,
        used_date               timestamptz,
        amount_reinstated       numeric,
        reinstated_date         timestamp
);

create index ec_gift_cert_by_id on ec_gift_certificate_usage (gift_certificate_id);


--------- customer service --------------------

create sequence ec_issue_id_seq;
create view ec_issue_id_sequence as select nextval('ec_issue_id_seq') as nextval;
create sequence ec_action_id_seq;
create view ec_action_id_sequence as select nextval('ec_action_id_seq') as nextval;
create sequence ec_interaction_id_seq;
create view ec_interaction_id_sequence as select nextval('ec_interaction_id_seq') as nextval;
create sequence ec_user_ident_id_seq;
create view ec_user_ident_id_sequence as select nextval('ec_user_ident_id_seq') as nextval;

-- this contains the bits of info a cs rep uses to identify
-- a user
-- often user_id is not known and the customer service rep
-- will have to get other info in order to identify the user
create table ec_user_identification (
        user_identification_id  integer not null primary key,
        date_added      	timestamptz,
        user_id         	integer references users,
        email           	varchar(100),
        first_names     	varchar(100),
        last_name       	varchar(100),
        -- this is varchar(80) in community-core.sql, so I'll be consistent
        postal_code     	varchar(80),
        other_id_info   	varchar(2000)
);

-- should index everything because this all columns may potentially
-- be searched through every time a new interaction is recorded
create index ec_user_ident_by_user_id on ec_user_identification(user_id);
create index ec_user_ident_by_email on ec_user_identification(email);
create index ec_user_ident_by_first_names on ec_user_identification(first_names);
create index ec_user_ident_by_last_name on ec_user_identification(last_name);
create index ec_user_ident_by_postal_code on ec_user_identification(postal_code);


-- puts date_added into ec_user_identification if it's missing
create function ec_user_identificate_date_tr ()
returns opaque as '
begin
        IF new.date_added is null THEN
                new.date_added := now();
        END IF;
	return new;
end;' language 'plpgsql';

create trigger ec_user_identificate_date_tr
after insert on ec_user_identification
for each row execute procedure ec_user_identificate_date_tr ();


create table ec_customer_serv_interactions (
        interaction_id          integer not null primary key,
        customer_service_rep    integer references users,
        user_identification_id  integer not null 
				    references ec_user_identification,
        interaction_date        timestamptz,
        interaction_originator  varchar(20) not null, -- e.g. customer, customer-service-rep, automatic
        interaction_type        varchar(30) not null, -- e.g. email, phone_call
        -- will be filled in if the customer-originated interaction is
        -- an email
        interaction_headers     varchar(4000)
);

create index ec_csin_by_user_ident_id on ec_customer_serv_interactions(user_identification_id);

-- gilbertw - used the code in OpenACS 3.2.5 as a reference
create function ec_cs_interaction_inserts ()
returns opaque as '
begin
 IF new.interaction_date is null THEN 
    new.interaction_date := now();
 END IF;
 return new;
end;' language 'plpgsql';

create trigger ec_cs_interaction_inserts
after insert on ec_customer_serv_interactions
for each row execute procedure ec_cs_interaction_inserts ();

create view ec_customer_service_reps
as
select * from cc_users 
where user_id in (select customer_service_rep 
	from ec_customer_serv_interactions)
   or user_id in (select issued_by from ec_gift_certificates_issued);

create table ec_customer_service_issues (
        issue_id        integer not null primary key,
        user_identification_id  integer not null references ec_user_identification,
        -- may be null if this issue isn't associated with an order
        order_id        integer references ec_orders,
        -- may be null if this issue isn't associated with a gift certificate
        gift_certificate_id     integer references ec_gift_certificates,
        open_date       timestamptz not null,
        close_date      timestamptz,
        -- customer service reps who closed the issue
        closed_by       integer references users,
        -- we never really delete issues
        deleted_p       boolean default 'f'
);

create index ec_csi_by_user_ident_id on ec_customer_service_issues(user_identification_id);
create index ec_csi_by_open_date on ec_customer_service_issues(open_date);

-- because an issue can have more than one issue_type
create table ec_cs_issue_type_map (
        issue_id        integer not null references ec_customer_service_issues,
        issue_type      varchar(40) not null -- e.g. billing, web site
);

create index ec_csitm_by_issue_id on ec_cs_issue_type_map(issue_id);
create index ec_csitm_by_issue_type on ec_cs_issue_type_map(issue_type);

-- gilbertw - used code OpenACS 3.2.5 as a reference
-- removed INSERTING
create function ec_cs_issue_inserts ()
returns opaque as '
begin
 IF new.open_date is null THEN 
    new.open_date := now();
 END IF;
 return new;
end;' language 'plpgsql';

create trigger ec_cs_issue_inserts
after insert on ec_customer_service_issues
for each row execute procedure ec_cs_issue_inserts ();

create table ec_customer_service_actions (
        action_id               integer not null primary key,
        issue_id                integer not null references ec_customer_service_issues,
        interaction_id          integer not null references ec_customer_serv_interactions,
        action_details          varchar(4000),
        follow_up_required      varchar(4000)
);
        
create index ec_csa_by_issue on ec_customer_service_actions(issue_id);

create table ec_cs_action_info_used_map (
        action_id               integer not null references ec_customer_service_actions,
        info_used               varchar(100) not null
);

create index ec_csaium_by_action_id on ec_cs_action_info_used_map(action_id);
create index ec_csaium_by_info_used on ec_cs_action_info_used_map(info_used);

-- this table contains picklist choices for the customer service data
-- entry people

create sequence ec_picklist_item_id_seq;
create view ec_picklist_item_id_sequence as select nextval('ec_picklist_item_id_seq') as nextval;

create table ec_picklist_items (
        picklist_item_id        integer not null primary key,
        -- pretty, human-readable
        picklist_item           varchar(100),
        -- which picklist this item is in
        picklist_name           varchar(100),
        sort_key                numeric,
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null
);

create table ec_picklist_items_audit (
        picklist_item_id        integer,
        picklist_item           varchar(100),
        picklist_name           varchar(100),
        sort_key                numeric,
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f'
);

create function ec_picklist_items_audit_tr ()
returns opaque as '
begin
        insert into ec_picklist_items_audit (
        picklist_item_id, picklist_item,
        picklist_name, sort_key,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.picklist_item_id, old.picklist_item,
        old.picklist_name, old.sort_key,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address
        );
	return new;
end;' language 'plpgsql';

create trigger ec_picklist_items_audit_tr
after update or delete on ec_picklist_items
for each row execute procedure ec_picklist_items_audit_tr ();

-- Canned responses for customer support
create sequence ec_canned_response_id_seq;
create view ec_canned_response_id_sequence as select nextval('ec_canned_response_id_seq') as nextval;

create table ec_canned_responses (
        response_id     integer not null primary key,
        one_line        varchar(100) not null,
        response_text   varchar(4000) not null
);

-----------------------------------------------

-- templates 1-6 are pre-defined (see the insert statements in 
-- ecommerce-defaults.sql)
-- the wording of each can be changed at [ec_url_concat [ec_url] /admin]/email-templates/
create sequence ec_email_template_id_seq start 7;
create view ec_email_template_id_sequence as select nextval('ec_email_template_id_seq') as nextval;

create table ec_email_templates (
        email_template_id       integer not null primary key,
        title                   varchar(100),
        subject                 varchar(200),
        message                 varchar(4000),
        -- this lists the variable names that customer service can
        -- use in this particular email -- for their info only
        variables               varchar(1000),
        -- for informational purposes only, when the email is
        -- sent
        when_sent               varchar(1000),
        -- for customer service issues, this is a tcl list of all
        -- the issue_types that should be inserted into 
        -- ec_cs_issue_type_map for the issue that will be created
        -- when the message is sent
        issue_type_list         varchar(100),
        last_modified           timestamptz not null,
        last_modifying_user     integer not null references users,
        modified_ip_address     varchar(20) not null
);

create table ec_email_templates_audit (
        email_template_id       integer,
        title                   varchar(100),
        subject                 varchar(200),
        message                 varchar(4000),
        variables               varchar(1000),
        when_sent               varchar(1000),
        issue_type_list         varchar(100),
        last_modified           timestamptz,
        last_modifying_user     integer,
        modified_ip_address     varchar(20),
        delete_p                boolean default 'f' 
);

create function ec_email_templates_audit_tr ()
returns opaque as '
begin
        insert into ec_email_templates_audit (
        email_template_id, title,
        subject, message,
        variables, when_sent,
        issue_type_list,
        last_modified,
        last_modifying_user, modified_ip_address
        ) values (
        old.email_template_id, old.title,
        old.subject, old.message,
        old.variables, old.when_sent,
        old.issue_type_list,
        old.last_modified,
        old.last_modifying_user, old.modified_ip_address
        );
	return new;
end;' language 'plpgsql';

create trigger ec_email_templates_audit_tr
after update or delete on ec_email_templates
for each row execute procedure ec_email_templates_audit_tr ();

-- 6 default templates are predefined ecommerce-defaults.
-- The templates are
-- used in procedures which send out the email, so the template_ids
-- shouldn t be changed, although the text can be edited at
-- [ec_url_concat [ec_url] /admin]/email-templates/
--
-- email_template_id    used for
-- -----------------    ---------
--      1               new order
--      2               order shipped
--      3               delayed credit denied
--      4               new gift certificate order
--      5               gift certificate recipient
--      6               gift certificate order failure


-- users can sign up for mailing lists based on category, subcategory,
-- or subsubcategory (the appropriate level of categorization on which
-- to base mailing lists depends on how the site administrator has
-- set up their system)
-- when the user is signed up for a subsubcategory list, the subcategory_id
-- and category_id are also filled in (which makes it easier to refer
-- to the mailing list later).
-- cat stands for categorization
create table ec_cat_mailing_lists (
        user_id                 integer not null references users,
        category_id             integer references ec_categories,
        subcategory_id          integer references ec_subcategories,
        subsubcategory_id       integer references ec_subsubcategories
);

create index ec_cat_mailing_list_idx on ec_cat_mailing_lists(user_id);
create index ec_cat_mailing_list_idx2 on ec_cat_mailing_lists(category_id);
create index ec_cat_mailing_list_idx3 on ec_cat_mailing_lists(subcategory_id);
create index ec_cat_mailing_list_idx4 on ec_cat_mailing_lists(subsubcategory_id);

create sequence ec_spam_id_seq;
create view ec_spam_id_sequence as select nextval('ec_spam_id_seq') as nextval;

create table ec_spam_log (
        spam_id                 integer not null primary key,
        spam_date               timestamptz,
        spam_text               varchar(4000),
        -- the following are all criteria used in choosing the users to be spammed
        mailing_list_category_id        integer references ec_categories,
        mailing_list_subcategory_id     integer references ec_subcategories,
        mailing_list_subsubcategory_id  integer references ec_subsubcategories,
        user_class_id                   integer references ec_user_classes,
        product_id                      integer references ec_products,
        last_visit_start_date           timestamptz,
        last_visit_end_date             timestamp
);

create index ec_spam_log_by_cat_mail_idx on ec_spam_log (mailing_list_category_id);
create index ec_spam_log_by_cat_mail_idx2 on ec_spam_log (mailing_list_subcategory_id);
create index ec_spam_log_by_cat_mail_idx3 on ec_spam_log (mailing_list_subsubcategory_id);
create index ec_spam_log_by_user_cls_idx on ec_spam_log (user_class_id);
create index ec_spam_log_by_product_idx on ec_spam_log (product_id);



-- CREDIT CARD STUFF ------------------------
---------------------------------------------

create sequence ec_transaction_id_seq start 4000000;
create view ec_transaction_id_sequence as select nextval('ec_transaction_id_seq') as nextval;

create table ec_financial_transactions (
        transaction_id          varchar(20) not null primary key,
	-- The charge transaction that a refund transaction refunded.
	refunded_transaction_id varchar(20) references ec_financial_transactions,
        -- order_id or gift_certificate_id must be filled in
        order_id                integer references ec_orders,
        -- The following two rows were added 1999-08-11.  They re
        -- not actually needed by the system right now, but
        -- they might be useful in the future (I can envision them
        -- being useful as factory functions are automated).
        shipment_id             integer references ec_shipments,
        refund_id               integer references ec_refunds,
        -- this refers to the purchase of a gift certificate, not the use of one
        gift_certificate_id     integer references ec_gift_certificates,
        -- creditcard_id is in here even though order_id has a creditcard_id associated with
        -- it in case a different credit card is used for a refund or a partial shipment.
        -- a trigger fills the creditcard_id in if it s not specified
        creditcard_id           integer not null references ec_creditcards,
        transaction_amount      numeric not null,
        refunded_amount      	numeric,
        -- charge doesn't imply that a charge will actually occur; it s just
        -- an authorization to charge
        -- in the case of a refund, theres no such thing as an authorization
        -- to refund, so the refund really will occur
        transaction_type        varchar(6) not null check (transaction_type in ('charge','refund')),
        -- it starts out null, becomes t when we want to capture it, or becomes
        -- f it is known that we don't want to capture the transaction (although
        -- the f is mainly just for reassurance; we only capture ones with t)
        -- There's no need to set this for refunds.  Refunds are always to be captured.
        to_be_captured_p        boolean, 
        inserted_date           timestamptz not null,
        authorized_date         timestamptz,
        -- set when to_be_captured_p becomes 't'; used in cron jobs
        to_be_captured_date     timestamptz,
        marked_date             timestamptz,
        refunded_date           timestamptz,
        -- if the transaction failed, this will keep the cron jobs from continuing
        -- to retry it
        failed_p                boolean default 'f',
        check (order_id is not null or gift_certificate_id is not null)
);

create index ec_finan_trans_by_order_idx on ec_financial_transactions (order_id);
create index ec_finan_trans_by_cc_idx on ec_financial_transactions (creditcard_id);
create index ec_finan_trans_by_gc_idx on ec_financial_transactions (gift_certificate_id);

-- reportable transactions: those which have not failed which are to
-- be captured (note: refunds are always to be captured)
create view ec_fin_transactions_reportable
as
select * from ec_financial_transactions
where (transaction_type='charge' and to_be_captured_p='t' and failed_p='f')
or (transaction_type='refund' and failed_p='f');


-- fills creditcard_id into ec_financial_transactions if it's missing
-- (using the credit card associated with the order)
create function fin_trans_ccard_update_tr ()
returns opaque as '
declare
        v_creditcard_id         ec_creditcards.creditcard_id%TYPE;
begin
        IF new.order_id is not null THEN
                select into v_creditcard_id creditcard_id 
		    from ec_orders where order_id=new.order_id;
                IF new.creditcard_id is null THEN
                        new.creditcard_id := v_creditcard_id;
                END IF;
        END IF;
	return new;
end;' language 'plpgsql';

create trigger fin_trans_ccard_update_tr
before insert on ec_financial_transactions
for each row execute procedure fin_trans_ccard_update_tr ();

-- END CREDIT CARD STUFF ----------------------------
-----------------------------------------------------


-- this is to record any problems that may have occurred so that the site administrator
-- can be alerted on the admin pages
create sequence ec_problem_id_seq;
create view ec_problem_id_sequence as select nextval('ec_problem_id_seq') as nextval;

create table ec_problems_log (
        problem_id      integer not null primary key,
        problem_date    timestamptz,
        problem_details varchar(4000),
        -- if it's related to an order
        order_id        integer references ec_orders,
        -- if it's related to a gift certificate
        gift_certificate_id     integer references ec_gift_certificates,
        resolved_date   timestamptz,
        resolved_by     integer references users
);


-- keeps track of automatic emails (based on templates) that are sent out
create table ec_automatic_email_log (
        user_identification_id  integer not null references ec_user_identification,
        email_template_id       integer not null references ec_email_templates,
        order_id                integer references ec_orders,
        shipment_id             integer references ec_shipments,
        gift_certificate_id     integer references ec_gift_certificates,
        date_sent               timestamp
);

create index ec_auto_email_by_usr_id_idx on ec_automatic_email_log (user_identification_id);
create index ec_auto_email_by_temp_idx on ec_automatic_email_log (email_template_id);
create index ec_auto_email_by_order_idx on ec_automatic_email_log (order_id);
create index ec_auto_email_by_shipment_idx on ec_automatic_email_log (shipment_id);
create index ec_auto_email_by_gc_idx on ec_automatic_email_log (gift_certificate_id);


--
-- ecommerce-plsql.sql
--
-- by eveander@arsdigita.com, April 1999
--

--------------- price calculations -------------------
-------------------------------------------------------

-- just the price of an order, not shipping, tax, or gift certificates
-- this is actually price_charged minus price_refunded
create function ec_total_price (integer) 
returns numeric as '
DECLARE
	v_order_id	alias for $1;
        price           numeric;
BEGIN
	select into price
	    coalesce(sum(price_charged),0) - coalesce(sum(price_refunded),0)
            FROM ec_items
            WHERE order_id=v_order_id
            and item_state <> ''void'';

	return price;

END;' language 'plpgsql';


-- just the shipping of an order, not price, tax, or gift certificates
-- this is actually total shipping minus total shipping refunded
create function ec_total_shipping (integer)
returns numeric as '
DECLARE
	v_order_id		alias for $1;
        order_shipping          numeric;
        item_shipping           numeric;
BEGIN
        select into order_shipping
        coalesce(shipping_charged,0) - coalesce(shipping_refunded,0)
        FROM ec_orders
        WHERE order_id=v_order_id;

        select into item_shipping
        coalesce(sum(shipping_charged),0) - coalesce(sum(shipping_refunded),0)
        FROM ec_items
        WHERE order_id=v_order_id
        and item_state <> ''void'';

        return order_shipping + item_shipping;
END;' language 'plpgsql';

-- OK
-- just the tax of an order, not price, shipping, or gift certificates
-- this is tax minus tax refunded
create function ec_total_tax (integer)
returns numeric as '
DECLARE
	v_order_id			alias for $1;
        order_tax               	numeric;
        item_price_tax          	numeric;
        item_shipping_tax       	numeric;
BEGIN
        select into order_tax
        coalesce(shipping_tax_charged,0) - coalesce(shipping_tax_refunded,0)
        FROM ec_orders
        WHERE order_id=v_order_id;

        select into item_price_tax
        coalesce(sum(price_tax_charged),0) - coalesce(sum(price_tax_refunded),0)
        FROM ec_items
        WHERE order_id=v_order_id
        and item_state <> ''void'';

        select into item_shipping_tax
        coalesce(sum(shipping_tax_charged),0) - coalesce(sum(shipping_tax_refunded),0)
        FROM ec_items
        WHERE order_id=v_order_id;

        return order_tax + item_price_tax + item_shipping_tax;
END;' language 'plpgsql';


-- OK
-- just the price of a shipment, not shipping, tax, or gift certificates
-- this is the price charged minus the price refunded of the shipment
create function ec_shipment_price (integer)
returns numeric as '
DECLARE
	v_shipment_id		alias for $1;
        shipment_price          numeric;
BEGIN
        SELECT into shipment_price coalesce(sum(price_charged),0) - coalesce(sum(price_refunded),0)
        FROM ec_items
        WHERE shipment_id=v_shipment_id
        and item_state <> ''void'';

        RETURN shipment_price;
END;' language 'plpgsql';

-- OK
-- just the shipping charges of a shipment, not price, tax, or gift certificates
-- note: the base shipping charge is always applied to the first shipment in an order.
-- this is the shipping charged minus the shipping refunded
create function ec_shipment_shipping (integer)
returns numeric as '
DECLARE
	v_shipment_id 		alias for $1;
        item_shipping           numeric;
        base_shipping           numeric;
        v_order_id              ec_orders.order_id%TYPE;
        min_shipment_id         ec_shipments.shipment_id%TYPE;
BEGIN
        SELECT into v_order_id order_id 
	    FROM ec_shipments where shipment_id=v_shipment_id;
        SELECT into min_shipment_id min(s.shipment_id) 
	    from ec_shipments s, ec_items i, ec_products p
	    where s.order_id = v_order_id
	    and s.shipment_id = i.shipment_id
	    and i.product_id = p.product_id
	    and p.no_shipping_avail_p = ''f'';
        IF v_shipment_id=min_shipment_id THEN
                SELECT into base_shipping 
		    coalesce(shipping_charged,0) - coalesce(shipping_refunded,0)
		    FROM ec_orders where order_id=v_order_id;
        ELSE
                base_shipping := 0;
        END IF;
        SELECT into item_shipping 
	    coalesce(sum(shipping_charged),0) - coalesce(sum(shipping_refunded),0) 
	    FROM ec_items where shipment_id=v_shipment_id 
	    and item_state <> ''void'';
        RETURN item_shipping + base_shipping;
END;' language 'plpgsql';

-- OK
-- just the tax of a shipment, not price, shipping, or gift certificates
-- note: the base shipping tax charge is always applied to the first shipment in an order.
-- this is the tax charged minus the tax refunded
create function ec_shipment_tax (integer)
returns numeric as '
DECLARE
	v_shipment_id 		alias for $1;
        item_price_tax          numeric;
        item_shipping_tax       numeric;
        base_shipping_tax       numeric;
        v_order_id              ec_orders.order_id%TYPE;
        min_shipment_id         ec_shipments.shipment_id%TYPE;
BEGIN
        SELECT into v_order_id order_id 
	    FROM ec_shipments where shipment_id=v_shipment_id;
        SELECT into min_shipment_id min(s.shipment_id) 
	    from ec_shipments s, ec_items i, ec_products p
	    where s.order_id = v_order_id
	    and s.shipment_id = i.shipment_id
	    and i.product_id = p.product_id
	    and p.no_shipping_avail_p = ''f'';
        IF v_shipment_id=min_shipment_id THEN
                SELECT into base_shipping_tax 
		coalesce(shipping_tax_charged,0) - coalesce(shipping_tax_refunded,0) 
		FROM ec_orders where order_id=v_order_id;
        ELSE
                base_shipping_tax := 0;
        END IF;
        SELECT into item_price_tax 
	coalesce(sum(price_tax_charged),0) - coalesce(sum(price_tax_refunded),0) 
	FROM ec_items where shipment_id=v_shipment_id and item_state <> ''void'';
        SELECT into item_shipping_tax 
	coalesce(sum(shipping_tax_charged),0) - coalesce(sum(shipping_tax_refunded),0) 
	FROM ec_items where shipment_id=v_shipment_id and item_state <> ''void'';
        RETURN item_price_tax + item_shipping_tax + base_shipping_tax;
END;' language 'plpgsql';


-- OK
-- the gift certificate amount used on one order
create function ec_order_gift_cert_amount (integer)
returns numeric as '
DECLARE
	v_order_id		alias for $1;
        gift_cert_amount        numeric;
BEGIN
        select into gift_cert_amount
        coalesce(sum(amount_used),0) - coalesce(sum(amount_reinstated),0)
        FROM ec_gift_certificate_usage
        WHERE order_id=v_order_id;

        return gift_cert_amount;
END;' language 'plpgsql';


-- OK
-- tells how much of the gift certificate amount used on the order is to be applied
-- to a shipment (it's applied chronologically)
create function ec_shipment_gift_certificate (integer)
returns numeric as '
DECLARE
	v_shipment_id		alias for $1;
        v_order_id              ec_orders.order_id%TYPE;
        gift_cert_amount        numeric;
        past_ship_amount        numeric;
BEGIN
        SELECT into v_order_id order_id 
	    FROM ec_shipments WHERE shipment_id=v_shipment_id;
        gift_cert_amount := ec_order_gift_cert_amount(v_order_id);
        SELECT into past_ship_amount 
	    coalesce(sum(ec_shipment_price(shipment_id)) + sum(ec_shipment_shipping(shipment_id))+sum(ec_shipment_tax(shipment_id)),0) 
	    FROM ec_shipments WHERE order_id = v_order_id and shipment_id <> v_shipment_id;

        IF past_ship_amount > gift_cert_amount THEN
                return 0;
        ELSE
                return least(gift_cert_amount - past_ship_amount, coalesce(ec_shipment_price(v_shipment_id) + ec_shipment_shipping(v_shipment_id) + ec_shipment_tax(v_shipment_id),0));
        END IF;
END;' language 'plpgsql';

--CHECK OUTER JOIN BELOW

-- OK
-- this can be used for either an item or order
-- given price and shipping, computes tax that needs to be charged (or refunded)
-- order_id is an argument so that we can get the usps_abbrev (and thus the tax rate),
create function ec_tax (numeric, numeric, integer) 
returns numeric as '
DECLARE
	v_price			alias for $1;
	v_shipping		alias for $2;
	v_order_id		alias for $3;
        taxes                   ec_sales_tax_by_state%ROWTYPE;
        tax_exempt_p            ec_orders.tax_exempt_p%TYPE;
BEGIN
        SELECT into tax_exempt_p tax_exempt_p 
        FROM ec_orders
        WHERE order_id = v_order_id;

        IF tax_exempt_p = ''t'' THEN
                return 0;
        END IF; 
        
        --SELECT t.* into taxes
        --FROM ec_orders o, ec_addresses a, ec_sales_tax_by_state t
        --WHERE o.shipping_address=a.address_id
        --AND a.usps_abbrev=t.usps_abbrev(+)
        --AND o.order_id=v_order_id;

        SELECT into taxes t.* 
	FROM ec_orders o
	    JOIN 
	ec_addresses a on (o.shipping_address=a.address_id)
	    LEFT JOIN
	ec_sales_tax_by_state t using (usps_abbrev)
	WHERE o.order_id=v_order_id;
	

        IF coalesce(taxes.shipping_p,''f'') = ''f'' THEN
                return coalesce(taxes.tax_rate,0) * v_price;
        ELSE
                return coalesce(taxes.tax_rate,0) * (v_price + v_shipping);
        END IF;
END;' language 'plpgsql';

-- OK
-- total order cost (price + shipping + tax - gift certificate)
-- this should be equal to the amount that the order was authorized for
-- (if no refunds have been made)
create function ec_order_cost (integer)
returns numeric as '
DECLARE
	v_order_id	alias for $1;
        v_price         numeric;
        v_shipping      numeric;
        v_tax           numeric;
        v_certificate   numeric;
BEGIN
        v_price := ec_total_price(v_order_id);
        v_shipping := ec_total_shipping(v_order_id);
        v_tax := ec_total_tax(v_order_id);
        v_certificate := ec_order_gift_cert_amount(v_order_id);

        return v_price + v_shipping + v_tax - v_certificate;
END;' language 'plpgsql';

-- OK
-- total shipment cost (price + shipping + tax - gift certificate)
create function ec_shipment_cost (integer)
returns numeric as '
DECLARE
	v_shipment_id	alias for $1;
        v_price         numeric;
        v_shipping      numeric;
        v_certificate   numeric;
        v_tax           numeric;
BEGIN
        v_price := ec_shipment_price(v_shipment_id);
        v_shipping := ec_shipment_shipping(v_shipment_id);
        v_tax := ec_shipment_tax(v_shipment_id);
        v_certificate := ec_shipment_gift_certificate(v_shipment_id);

        return v_price + v_shipping - v_certificate + v_tax;
END;' language 'plpgsql';

-- OK
-- total amount refunded on an order so far
create function ec_total_refund (integer)
returns numeric as '
DECLARE
	v_order_id 	alias for $1;
        v_order_refund  numeric;
        v_items_refund  numeric;
BEGIN
        select into v_order_refund 
	    coalesce(shipping_refunded,0) + coalesce(shipping_tax_refunded,0) 
	    from ec_orders where order_id=v_order_id;
        select into v_items_refund 
	    sum(coalesce(price_refunded,0)) + sum(coalesce(shipping_refunded,0)) + sum(coalesce(price_tax_refunded,0)) + sum(coalesce(shipping_tax_refunded,0)) from ec_items where order_id=v_order_id;
        return v_order_refund + v_items_refund;
END;' language 'plpgsql';

-------------- end price calculations -----------------
-------------------------------------------------------


----------- gift certificate procedures ---------------
-------------------------------------------------------
  
-- gilbertw - removed global temporary table ec_gift_cert_usage_ids
-- copied code from openacs 3.2.5

--
-- BMA (PGsql port)
-- Postgres is way cooler than Oracle with MVCC, which allows it
-- to have triggers updating the same table. Thus, we get rid of this
-- trio crap and we have a simple trigger for everything.

create function trig_ec_cert_amount_remains()
returns opaque
as '
DECLARE
        bal_amount_used         numeric;
        original_amount         numeric;
BEGIN
        select amount into original_amount
        from ec_gift_certificates where gift_certificate_id= NEW.certificate_id for update;

        select coalesce(sum(amount_used), 0) - coalesce(sum(amount_reinstated), 0)
        into bal_amount_used
        from ec_gift_certificate_usage
        where gift_certificate_id= NEW.gift_certificate_id;

        UPDATE ec_gift_certificates
        SET amount_remaining_p = case when amount > bal_amount_used then ''t'' else ''f'' end
        WHERE gift_certificate_id = gift_certificate_rec.gift_certificate_id;
	return new;
END;
' language 'plpgsql';

create trigger ec_cert_amount_remains
after update on ec_gift_certificate_usage
for each row
execute procedure trig_ec_cert_amount_remains();


-- OK
-- calculates how much a user has in their gift certificate account
create function ec_gift_certificate_balance (integer)
returns numeric as '
DECLARE
	v_user_id alias for $1;
	original_amount                 numeric;
	total_amount_used               numeric;
        -- these only look at unexpired gift certificates 
	-- where amount_remaining_p is t,
        -- hence the word subset in their names
BEGIN
        SELECT coalesce(sum(amount),0)
	into original_amount
        FROM ec_gift_certificates_approved
        WHERE user_id=v_user_id
        AND amount_remaining_p=''t''
        AND expires > now();

        SELECT coalesce(sum(u.amount_used),0) - 
    	    coalesce(sum(u.amount_reinstated),0)
	into total_amount_used
        FROM ec_gift_certificates_approved c, ec_gift_certificate_usage u
        WHERE c.gift_certificate_id=u.gift_certificate_id
        AND c.user_id=v_user_id
        AND c.amount_remaining_p=''t''
        AND c.expires > now();

        RETURN original_amount - total_amount_used;
END;' language 'plpgsql';

-- OK
-- Returns price + shipping + tax - gift certificate amount applied
-- for one order.
-- Requirement: ec_orders.shipping_charged, ec_orders.shipping_tax_charged,
-- ec_items.price_charged, ec_items.shipping_charged, ec_items.price_tax_chaged,
-- and ec_items.shipping_tax_charged should already be filled in.

create function ec_order_amount_owed (integer)
returns numeric as '
DECLARE
	v_order_id			alias for $1;
        pre_gc_amount_owed              numeric;
        gc_amount                       numeric;
BEGIN
        pre_gc_amount_owed := ec_total_price(v_order_id) + ec_total_shipping(v_order_id) + ec_total_tax(v_order_id);
        gc_amount := ec_order_gift_cert_amount(v_order_id);

        RETURN pre_gc_amount_owed - gc_amount;
END;' language 'plpgsql';

-- OK
-- the amount remaining in an individual gift certificate
create function gift_certificate_amount_left (integer)
returns numeric as '
DECLARE
	v_gift_certificate_id 	alias for $1;
        original_amount         numeric;
        total_amount_used       numeric;
BEGIN
        SELECT coalesce(sum(amount_used),0) - coalesce(sum(amount_reinstated),0)
	into total_amount_used
        FROM ec_gift_certificate_usage
        WHERE gift_certificate_id = v_gift_certificate_id;

        SELECT amount
	into original_amount
        FROM ec_gift_certificates
        WHERE gift_certificate_id = v_gift_certificate_id;

        RETURN original_amount - total_amount_used;
END;' language 'plpgsql';

-- I DON'T USE THIS PROCEDURE ANYMORE BECAUSE THERE'S A MORE
-- FAULT-TOLERANT TCL VERSION
-- This applies gift certificate balance to an entire order
-- by iteratively applying unused/unexpired gift certificates
-- to the order until the order is completely paid for or
-- the gift certificates run out.
-- Requirement: ec_orders.shipping_charged, ec_orders.shipping_tax_charged,
-- ec_items.price_charged, ec_items.shipping_charged, ec_items.price_tax_charged,
-- ec_items.shipping_tax_charged should already be filled in.
-- Call this within a transaction.
--create or replace procedure ec_apply_gift_cert_balance (v_order_id IN integer, v_user_id IN integer)
--IS
--        CURSOR gift_certificate_to_use_cursor IS
--                SELECT *
--                FROM ec_gift_certificates_approved
--                WHERE user_id = v_user_id
--                AND (expires is null or now() < expires )
--                AND amount_remaining_p = ''t''
--                ORDER BY expires;
--        amount_owed                     number;
--        gift_certificate_balance        number;
--        certificate                     ec_gift_certificates_approved%ROWTYPE;
--BEGIN
--        gift_certificate_balance := ec_gift_certificate_balance(v_user_id);
--        amount_owed := ec_order_amount_owed(v_order_id);
--
--        OPEN gift_certificate_to_use_cursor;
--        WHILE amount_owed > 0 and gift_certificate_balance > 0
--                LOOP
--                        FETCH gift_certificate_to_use_cursor INTO certificate;
--
--                        INSERT into ec_gift_certificate_usage
--                        (gift_certificate_id, order_id, amount_used, used_date)
--                        VALUES
--                        (certificate.gift_certificate_id, v_order_id, least(gift_certificate_amount_left(certificate.gift_certificate_id), amount_owed), now());
--
--                        gift_certificate_balance := ec_gift_certificate_balance(v_user_id);
--                        amount_owed := ec_order_amount_owed(v_order_id);        
--                END LOOP;
--        CLOSE gift_certificate_to_use_cursor;
--END ec_apply_gift_cert_balance;
--/
--show errors

-- OK
-- reinstates all gift certificates used on an order (as opposed to
-- individual items), e.g. if the order was voided or an auth failed

create function ec_reinst_gift_cert_on_order (integer)
returns integer as '
DECLARE
	v_order_id	alias for $1;
BEGIN
        insert into ec_gift_certificate_usage
        (gift_certificate_id, order_id, amount_reinstated, reinstated_date)
        select gift_certificate_id, v_order_id, coalesce(sum(amount_used),0)-coalesce(sum(amount_reinstated),0), now()
        from ec_gift_certificate_usage
        where order_id=v_order_id
        group by gift_certificate_id;

	return 0;
END;' language 'plpgsql';

-- Given an amount to refund to an order, this tells
-- you how much of that is to be refunded in cash (as opposed to 
-- reinstated in gift certificates).  Then you know you have to
-- go and reinstate v_amount minus (what this function returns)
-- in gift certificates.
-- (when I say cash I'm really talking about credit card
-- payment -- as opposed to gift certificates)

-- Call this before inserting the amounts that are being refunded
-- into the database.
create function ec_cash_amount_to_refund (numeric, integer) 
returns numeric as '
DECLARE
	v_amount			alias for $1;
	v_order_id			alias for $2;
        amount_paid                     numeric;
        items_amount_paid               numeric;
        order_amount_paid               numeric;
        amount_refunded                 numeric;
        curr_gc_amount                  numeric;
        max_cash_refundable             numeric;
        cash_to_refund                  numeric;
BEGIN
        -- the maximum amount of cash refundable is equal to
        -- the amount paid (in cash + certificates) for shipped items only (since
        --  money is not paid until an item actually ships)
        -- minus the amount refunded (in cash + certificates) (only occurs for shipped items)
        -- minus the current gift certificate amount applied to this order
        -- or 0 if the result is negative

        select sum(coalesce(price_charged,0)) + sum(coalesce(shipping_charged,0)) + sum(coalesce(price_tax_charged,0)) + sum(coalesce(shipping_tax_charged,0)) into items_amount_paid from ec_items where order_id=v_order_id and shipment_id is not null and item_state <> ''void'';

        select coalesce(shipping_charged,0) + coalesce(shipping_tax_charged,0) into order_amount_paid from ec_orders where order_id=v_order_id;

        amount_paid := items_amount_paid + order_amount_paid;
        amount_refunded := ec_total_refund(v_order_id);
        curr_gc_amount := ec_order_gift_cert_amount(v_order_id);
        
        max_cash_refundable := amount_paid - amount_refunded - curr_gc_amount;
        cash_to_refund := least(max_cash_refundable, v_amount);

        RETURN cash_to_refund;
END;' language 'plpgsql';

-- The amount of a given gift certificate used on a given order.
-- This is a helper function for ec_gift_cert_unshipped_amount.
create function ec_one_gift_cert_on_one_order (integer, integer) 
returns numeric as '
DECLARE
	v_gift_certificate_id	alias for $1;
	v_order_id		alias for $2;
        bal_amount_used         numeric;
BEGIN
        select coalesce(sum(amount_used),0)-coalesce(sum(amount_reinstated),0) into bal_amount_used
        from ec_gift_certificate_usage
        where order_id=v_order_id
        and gift_certificate_id=v_gift_certificate_id;

        RETURN bal_amount_used;

END;' language 'plpgsql'; 

-- The amount of all gift certificates used on a given order that
-- expire before* a given gift certificate (*in the event that two
-- expire at precisely the same time, the one with a higher
-- gift_certificate_id is defined to expire last).
-- This is a helper function for ec_gift_cert_unshipped_amount.
create function ec_earlier_certs_on_one_order (integer, integer)
returns numeric as '
DECLARE
	v_gift_certificate_id	alias for $1;
	v_order_id		alias for $2;
        bal_amount_used         numeric;
BEGIN
        select coalesce(sum(u.amount_used),0)-coalesce(sum(u.amount_reinstated),0) into bal_amount_used
        from ec_gift_certificate_usage u, ec_gift_certificates g, ec_gift_certificates g2
        where u.gift_certificate_id=g.gift_certificate_id
        and g2.gift_certificate_id=v_gift_certificate_id
        and u.order_id=v_order_id
        and (g.expires < g2.expires or (g.expires = g2.expires and g.gift_certificate_id < g2.gift_certificate_id));

        return bal_amount_used;
END;' language 'plpgsql';

-- The amount of a gift certificate that is applied to the upshipped portion of an order.
-- This is a helper function for ec_gift_cert_unshipped_amount.
create function ec_cert_unshipped_one_order (integer, integer)
returns numeric as '
DECLARE
	v_gift_certificate_id	alias for $1;	
	v_order_id		alias for $2;
        total_shipment_cost     numeric;
        earlier_certs           numeric;
        total_tied_amount       numeric;
BEGIN
        select coalesce(sum(coalesce(ec_shipment_price(shipment_id),0) + coalesce(ec_shipment_shipping(shipment_id),0) + coalesce(ec_shipment_tax(shipment_id),0)),0) into total_shipment_cost
        from ec_shipments
        where order_id=v_order_id;

        earlier_certs := ec_earlier_certs_on_one_order(v_gift_certificate_id, v_order_id);

        IF total_shipment_cost <= earlier_certs THEN
                total_tied_amount := ec_one_gift_cert_on_one_order(v_gift_certificate_id, v_order_id);
        ELSE
	    IF total_shipment_cost > earlier_certs + ec_one_gift_cert_on_one_order(v_gift_certificate_id, v_order_id) THEN
                total_tied_amount := 0;
            ELSE
                total_tied_amount := ec_one_gift_cert_on_one_order(v_gift_certificate_id, v_order_id) - (total_shipment_cost - earlier_certs);
	    END IF;
        END IF;

        RETURN total_tied_amount;               
END;' language 'plpgsql';

--HERE

-- Returns the amount of a gift certificate that is applied to the unshipped portions of orders
-- (this amount is still considered outstanding since revenue, and thus gift certificate usage,
-- isnt recognized until the items ship).
create function ec_gift_cert_unshipped_amount (integer)
returns numeric as '
DECLARE
	v_gift_certificate_id		alias for $1;
        tied_but_unshipped_amount       numeric;
BEGIN
        select coalesce(sum(ec_cert_unshipped_one_order(v_gift_certificate_id,order_id)),0) into tied_but_unshipped_amount
        from ec_orders
        where order_id in (select distinct order_id from ec_gift_certificate_usage where gift_certificate_id=v_gift_certificate_id);

        return tied_but_unshipped_amount;
END;' language 'plpgsql';

---------- end gift certificate procedures ------------
-------------------------------------------------------

\i pl-sql-utilities.sql
\i ec-product-package-create.sql
\i ecommerce-defaults.sql
\i ec-product-sc-create.sql
\i ecds-create.sql

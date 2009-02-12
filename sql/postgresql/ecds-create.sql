
-- this is a temporary table for ecds vendors
-- to be moved into the old contacts page real soon now.
-- 
 CREATE TABLE ecds_vendors (
   abbrev varchar(16) unique,
   title varchar(100),
   terms integer default 0,
   taxincluded varchar(1) default 'f',
   vendornumber varchar(32),
   gifi_accno varchar(30),
   business_id integer,
   taxnumber varchar(32),
   sic_code varchar(15),
   discount numeric,
   creditlimit numeric default 0,
   iban varchar(34),
   bic varchar(11),
   employee_id integer,
   language_code varchar(6),
   pricegroup_id integer,
   curr char(3),
   startdate date,
   enddate date
 );


create index ecds_vendors_abbrev_idx on ecds_vendors (abbrev);

--
-- only add the key for the specific two columns
-- with one being cat_key. Others should be null
--

create table ecds_categories_map (
    category_id integer unique,
    subcategory_id integer unique,
    subsubcategory_id integer unique,
    cat_key varchar(300) unique not null
);

create index ecds_categories_map_ec_category_id_idx on ecds_categories_map (category_id);
create index ecds_categories_map_ec_subcategory_id_idx on ecds_categories_map (subcategory_id);
create index ecds_categories_map_ec_subsubcategory_id_idx on ecds_categories_map (subsubcategory_id);
create index ecds_categories_map_ec_cat_key_idx on ecds_categories_map (cat_key);

create table ecds_categories (
    cat_key     varchar(300) not null primary key,
    type        varchar(80),
    url         varchar(300),
    icon_html   varchar(300),
    keywords    varchar(4000),
    title       varchar(300), 
    description varchar(4000),
    website_url varchar(300),
    notes       text
);
-- type is in set of cat, dept, mfg/brand etc

create index ecds_categories_cat_key_idx on ecds_categories (cat_key);

create table ecds_alt_spelling_map (
    context      varchar(30) not null,
    alt_spelling varchar(200) not null,
    normalized   varchar(200) not null
);
-- context may be a category_type, supplier_code etc.

create index ecds_alt_spelling_map_context_idx on ecds_alt_spelling_map (context);
create index ecds_alt_spelling_map_alt_spelling_idx on ecds_alt_spelling_map (alt_spelling);
create index ecds_alt_spelling_map_normalized_idx on ecds_alt_spelling_map (normalized);

--
-- templates
--

create table ecds_templates (
    template_id      integer primary key not null,
    package_id       integer,
    template_type_id integer,
    template_name    varchar(200),
    template text
);

create index ecds_templates_template_id_idx on ecds_templates (template_id);

create table ecds_object_templates_map (
    object_id           integer primary key,
    template_id         integer not null,
    template_parameters varchar(4000)
);

create index ecds_object_templates_map_object_id_idx on ecds_object_templates_map (object_id);
create index ecds_object_templates_map_template_id_idx on ecds_object_templates_map (template_id);

--
-- web bot cache
--

create table ecds_url_cache_map (
    url            varchar(300) not null,
    cache_filepath varchar(200) not null,
    last_update    timestamptz not null,
    flags          varchar(100)
);

create index ecds_url_cache_map_url_idx on ecds_url_cache_map (url);

---
--- product_id cross reference to file cache url
--- 

create table ecds_product_id_site_url_map (
    site_url        varchar(300) primary key not null,
    product_id      integer unique not null

);
-- site_map refers to local, static, url of a product, relative to (tailing) ec_url

create index ecds_product_id_site_url_map_site_url_idx on ecds_product_id_site_url_map (site_url);
create index ecds_product_id_site_url_map_product_idx on ecds_product_id_site_url_map (product_id);


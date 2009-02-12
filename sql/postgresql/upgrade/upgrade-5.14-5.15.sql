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

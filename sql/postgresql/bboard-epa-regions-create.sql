-- LOAD DATA
-- INFILE *
-- INTO TABLE BBOARD_EPA_REGIONS
-- REPLACE
-- FIELDS TERMINATED BY '|'
-- (
-- state_name
-- ,fips_numeric_code
-- ,epa_region
-- ,usps_abbrev
-- ,description
-- )
-- BEGINDATA
/* Loading BBOARD EPA REGIONS */
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Alabama','01',4,'AL','Southeast Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Alaska','02',10,'AK','Northwestern Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('American Samoa','60',9,'AS','Western Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Arizona','04',9,'AZ','Western Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Arkansas','05',6,'AR','Southern Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('California','06',9,'CA','Western Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Colorado','08',8,'CO','North Central Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Connecticut','09',1,'CT','New England Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Delaware','10',3,'DE','Mid Atlantic Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('District of Columbia','11',3,'DC','Mid Atlantic Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Florida','12',4,'FL','Southeast Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Georgia','13',4,'GA','Southeast Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Guam','66',9,'GU','Western Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Hawaii','15',9,'HI','Western Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Idaho','16',10,'ID','Northwestern Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Illinois','17',5,'IL','Great Lakes Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Indiana','18',5,'IN','Great Lakes Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Iowa','19',7,'IA','Central Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Kansas','20',7,'KS','Central Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Kentucky','21',4,'KY','Southeast Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Louisiana','22',6,'LA','Southern Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Maine','23',1,'ME','New England Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Maryland','24',3,'MD','Mid Atlantic Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Massachusetts','25',1,'MA','New England Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Michigan','26',5,'MI','Great Lakes Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Minnesota','27',5,'MN','Great Lakes Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Mississippi','28',4,'MS','Southeast Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Missouri','29',7,'MO','Central Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Montana','30',8,'MT','North Central Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Nebraska','31',7,'NE','Central Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Nevada','32',9,'NV','Western Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('New Hampshire','33',1,'NH','New England Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('New Jersey','34',2,'NJ','NY and NJ Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('New Mexico','35',6,'NM','Southern Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('New York','36',2,'NY','NY and NJ Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('North Carolina','37',4,'NC','Southeast Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('North Dakota','38',8,'ND','North Central Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Ohio','39',5,'OH','Great Lakes Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Oklahoma','40',6,'OK','Southern Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Oregon','41',10,'OR','Northwestern Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Pennsylvania','42',3,'PA','Mid Atlantic Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Puerto Rico','72',2,'PR','NY and NJ Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Rhode Island','44',1,'RI','New England Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('South Carolina','45',4,'SC','Southeast Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('South Dakota','46',8,'SD','North Central Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Tennessee','47',4,'TN','Southeast Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Texas','48',6,'TX','Southern Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Utah','49',8,'UT','North Central Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Vermont','50',1,'VT','New England Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Virgin Islands of the U.S.','78',2,'VI','NY and NJ Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Virginia','51',3,'VA','Mid Atlantic Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Washington','53',10,'WA','Northwestern Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('West Virginia','54',3,'WV','Mid Atlantic Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Wisconsin','55',5,'WI','Great Lakes Region');
insert into bboard_epa_regions (state_name, fips_numeric_code, epa_region, usps_abbrev, description)
values ('Wyoming','56',8,'WY','North Central Region');

--
-- acs-geo-tables/sql/acs-geo-tables-drop.sql
--
-- Calls the other SQL files to drop the data models and PL/SQL packages.
--
-- @author Jerry Asher jerry@hollyjerry.org
--
-- @creation-date 2001-02-17
--
-- @cvs-id $Id$
--

-- from acs 3.4.8 acs_geo_parents.sql

-- counties
-- used to be in acs/www/install/counties.dmp (with EDF tablespace)
-- data now in counties.ctl
DROP TABLE COUNTIES;

-- countries
-- used to be in acs/www/install/country-codes.dmp (with EDF tablespace)
-- data now in country_codes.ctl
DROP TABLE COUNTRY_CODES;

-- states
-- used to be in acs/www/install/states.dmp (with EDF tablespace)
-- data now in states.ctl
DROP TABLE STATES;

-- US EPA regions
-- used to be in acs/www/install/epa-regions.dmp (with EDF tablespace)
-- data now in bboard_epa_regions.ctl
DROP TABLE BBOARD_EPA_REGIONS;

-- currency codes
-- only the currencies with supported_p equal to t will be shown in the currency widget
DROP TABLE CURRENCY_CODES;

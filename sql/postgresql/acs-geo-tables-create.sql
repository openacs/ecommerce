--
-- acs-geo-tables/sql/acs-geo-tables-create.sql
--
-- Calls the other SQL files to create the data models and PL/SQL packages.
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
CREATE TABLE COUNTIES (
       FIPS_COUNTY_CODE     VARCHAR(5) NOT NULL,
       FIPS_COUNTY_NAME     VARCHAR(35) NOT NULL,
       FIPS_STATE_CODE      VARCHAR(2) NOT NULL,
       USPS_ABBREV          VARCHAR(2) NOT NULL,
       STATE_NAME           VARCHAR(50) NOT NULL,
       PRIMARY KEY (FIPS_COUNTY_CODE)
);

\i counties-create.sql

-- countries
-- used to be in acs/www/install/country-codes.dmp (with EDF tablespace)
-- data now in country_codes.ctl
CREATE TABLE COUNTRY_CODES (
       ISO                  CHAR(2) NOT NULL,
       COUNTRY_NAME         VARCHAR(150) NULL,
       PRIMARY KEY (ISO)
);

\i country-codes-create.sql

-- states
-- used to be in acs/www/install/states.dmp (with EDF tablespace)
-- data now in states.ctl
CREATE TABLE STATES (
       USPS_ABBREV          CHAR(2) NOT NULL,
       STATE_NAME           VARCHAR(25) NULL,
       FIPS_STATE_CODE      CHAR(2) NULL,
       PRIMARY KEY (USPS_ABBREV)
);

\i states-create.sql

-- US EPA regions
-- used to be in acs/www/install/epa-regions.dmp (with EDF tablespace)
-- data now in bboard_epa_regions.ctl
CREATE TABLE BBOARD_EPA_REGIONS (
       STATE_NAME           VARCHAR(30) NULL,
       FIPS_NUMERIC_CODE    CHAR(2) NULL,
       EPA_REGION           NUMERIC NULL,
       USPS_ABBREV          CHAR(2) NULL,
       DESCRIPTION          VARCHAR(50) NULL
);
\i bboard-epa-regions-create.sql

-- currency codes
-- only the currencies with supported_p equal to t will be shown in the currency widget
CREATE TABLE CURRENCY_CODES (
	ISO		CHAR(3) PRIMARY KEY,
	CURRENCY_NAME	VARCHAR(200),
	SUPPORTED_P	BOOLEAN DEFAULT 'f'
);


\i currency-codes-create.sql

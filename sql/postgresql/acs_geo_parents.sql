-- acs_geo_parents.sql

-- counties
-- used to be in acs/www/install/counties.dmp (with EDF tablespace)
-- data now in counties.ctl
CREATE TABLE COUNTIES (
       FIPS_COUNTY_CODE     VARCHAR2(5) NOT NULL,
       FIPS_COUNTY_NAME     VARCHAR2(35) NOT NULL,
       FIPS_STATE_CODE      VARCHAR2(2) NOT NULL,
       USPS_ABBREV          VARCHAR2(2) NOT NULL,
       STATE_NAME           VARCHAR2(50) NOT NULL,
       PRIMARY KEY (FIPS_COUNTY_CODE)
);


-- countries
-- used to be in acs/www/install/country-codes.dmp (with EDF tablespace)
-- data now in country_codes.ctl
CREATE TABLE COUNTRY_CODES (
       ISO                  CHAR(2) NOT NULL,
       COUNTRY_NAME         VARCHAR2(150) NULL,
       PRIMARY KEY (ISO)
);

-- states
-- used to be in acs/www/install/states.dmp (with EDF tablespace)
-- data now in states.ctl
CREATE TABLE STATES (
       USPS_ABBREV          CHAR(2) NOT NULL,
       STATE_NAME           VARCHAR2(25) NULL,
       FIPS_STATE_CODE      CHAR(2) NULL,
       PRIMARY KEY (USPS_ABBREV)
);

-- US EPA regions
-- used to be in acs/www/install/epa-regions.dmp (with EDF tablespace)
-- data now in bboard_epa_regions.ctl
CREATE TABLE BBOARD_EPA_REGIONS (
       STATE_NAME           VARCHAR2(30) NULL,
       FIPS_NUMERIC_CODE    CHAR(2) NULL,
       EPA_REGION           NUMBER NULL,
       USPS_ABBREV          CHAR(2) NULL,
       DESCRIPTION          VARCHAR2(50) NULL
);

-- currency codes
-- only the currencies with supported_p equal to t will be shown in the currency widget
CREATE TABLE CURRENCY_CODES (
	ISO		CHAR(3) PRIMARY KEY,
	CURRENCY_NAME	VARCHAR(200),
	SUPPORTED_P	CHAR(1) DEFAULT 'f' CHECK(SUPPORTED_P in ('t','f'))
);


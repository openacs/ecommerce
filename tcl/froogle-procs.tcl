# packages/ecommerce/tcl/froogle-procs.tcl

ad_library {
    
    Froogle (http://www.google.com/froogle) data feed
    procedures. See also http://www.google.com/froogle/merchants.html
    
    @author Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @creation-date 2004-05-19
    @arch-tag: f573c1b3-4533-4b1f-b3fd-d6914f96dd06
    @cvs-id $Id$
}

namespace eval froogle {
    namespace export upload
}

ad_proc -public froogle::upload {
} {
    Upload active products to a Froogle Ftp server. Intended to be
    run at scheduled intervals. The cronjob package is the preferred
    method.

    The product description submitted to Froogle is composed of the
    one line description and the detailed description both stripped from
    tabs, carriage-returns and newlines as well as HTML tags to conform
    to Froogle's strict data format.

    Products are assumed to be belong to only one category. Subcategories
    and sub-sub-categories are ignored as the site this procedure was
    written for doesn't use them.

    This proc relies on the ftp package in tcllib to perform the actual
    Ftp upload.
    
    @author Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @creation-date 2004-05-19
    
    @return Nothing 
    
    @error Standard Tcl error
} {
    set froogle_text "product_url\tname\tdescription\tprice\timage_url\tcategory\n"
    db_foreach get_products {} {

	# Build product and image URLs, strip description from HTML
	# tags as well as tabs, newlines and
	# carriage-returns. Retrieve the current lowest price.

	set product_url [ec_insecure_location][ec_url]product?product_id=$product_id
	regsub -all {\n|\r|\t} [util_remove_html_tags $description] {} description
	regsub -all { {2,}} $description { } description
	set price [format %.2f [lindex [ec_lowest_price_and_price_name_for_an_item $product_id 0] 0]]
	set image_url [ec_insecure_location][ec_url]product-file/[ec_product_file_directory $product_id]/$dirname/product.jpg
	append froogle_text "$product_url\t$name\t$description\t$price\t$image_url\t$category\n"
    }

    # Transfer the data to froogle.

    package require ftp
    set package_id [apm_package_id_from_key ecommerce]
    set ftp_hostname [parameter::get \
			  -package_id $package_id \
			  -parameter FroogleFtpHostname \
			  -default hedwig.google.com]
    set account_name [parameter::get \
			  -package_id $package_id \
			  -parameter FroogleAccountname \
			  -default 7_sisters]
    set password [parameter::get \
		      -package_id $package_id \
		      -parameter FrooglePassword]
    set th [::ftp::Open $ftp_hostname $account_name $password]
    if {$th >= 0} {
	if {![::ftp::Put $th -data $froogle_text ${account_name}.txt]} {
	    ns_log error "Could not transfer Froogle data to $ftp_hostname"
	} else {
	    ns_log notice "Updated Froogle data feed for $account_name on $ftp_hostname"
	}
	::ftp::Close $th
    } else {
	ns_log error "Could not open a Ftp connection to $ftp_hostname"
    }
}

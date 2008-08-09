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

    A copy of more recent output is saved in a file called: froogle-upload.txt
    Which can help with diagnostics and using an alternate method to ftp for
    uploading to froogle
    
    @author Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @creation-date 2004-05-19
    
    @return Nothing
    
    @error Standard Tcl error
} {

    set froogle_text "link\ttitle\tdescription\tprice\timage_link\tpayment_accepted\tpickup\ttax_region\tbrand\tcondition\tid\tproduct_type\tlocation\n"
#    ns_log Notice "froogle: $froogle_text"
    set brand_name ""
    set address_location "Mailville, DC 99999 USA"
    set place "Delaware"
    set payment_methods "Visa,Mastercard,American Express,Discover,WireTransfer"

    db_foreach get_products {} {

    # Build product and image URLs, strip description from HTML
    # tags as well as tabs, newlines and
    # carriage-returns. Retrieve the current lowest price.

    set product_url [ec_insecure_location][ec_url]product?product_id=$product_id

        # sanitize description, maybe use ad_html_to_text instead of util_remove_html_tags?
        set description [ec_remove_html_entities $description]

        # remove hiddent comments
        regsub -all -- {<!--[^-]*-->} $description {} description


        # remove html tags
        # first, convert an html list to something somewhat sane
        regsub -all {<ul>} $description {:  } description
        regsub -all {</li>} $description {,} description
        regsub -all {</ul>} $description {;} description
        regsub -all {,[ ]*;} $description {;} description
 
        regsub -all {<[^>]*>} $description { } description

        # remove multiple lines
        # regsub -all -- {\n|\r|\t} $description { } description
        # now expanded to
        # remove nonprintable characters
        regsub -all -- {[^\040-\177]} $description { } description

    regsub -all -- { {2,}} $description { } description
    set price [format %.2f [lindex [ec_lowest_price_and_price_name_for_an_item $product_id 0] 0]]
    set image_url [ec_insecure_location][ec_url]product-file/[ec_product_file_directory $product_id]/$dirname/product.jpg
    set product_type ""

    set line "${product_url}\t$name\t$description\t$price\t${image_url}\t${payment_methods}\ttrue\t${place}\t${brand_name}\tnew\t${product_id}\t${product_type}\t${address_location}\n"
        # santitize entire line for any more cases of html entities, such as in title or category etc.
        set line [ec_remove_html_entities $line]
#        ns_log Notice "froogle: $line"
    append froogle_text $line 
    }

    # Transfer the data to froogle.

    package require ftp
    set package_id [apm_package_id_from_key ecommerce]
    set ftp_hostname [parameter::get \
              -package_id $package_id \
              -parameter FroogleFtpHostname \
              -default test.openacs.com]
    set account_name [parameter::get \
              -package_id $package_id \
              -parameter FroogleAccountname \
              -default anonymous]
    
    set password [parameter::get \
              -package_id $package_id \
              -parameter FrooglePassword]

    set th [::ftp::Open $ftp_hostname $account_name $password]
    set return_message ""
    if {$th >= 0} {
    if {![::ftp::Put $th -data ${froogle_text} ${account_name}.txt]} {
            set return_message "Could not transfer Froogle data to ${ftp_hostname}." 
        ns_log Error ${return_message}
    } else {
            set return_message "Updated Froogle data feed for ${account_name} on ${ftp_hostname}."
        ns_log Notice ${return_message}

    }
    ::ftp::Close $th
    } else {
        set return_message "Could not open a Ftp connection to $ftp_hostname"
    ns_log Error ${return_message}
    }

            # put result in a file: froogle-upload.txt
            if { [catch {open [file join [ec_pageroot] admin products froogle-upload.txt] w} fileId] } {
                ns_log Error "froogle: unable to open file froogle-upload.txt for write. $fileId"
            } else {
                puts $fileId ${froogle_text}
                close $fileId
            }

}

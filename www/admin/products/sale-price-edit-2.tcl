ad_page_contract {

    Update a sale price.

    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date Summer 1999
    @author ported by Jerry Asher (jerry@theashergroup.com)
    @author revised by Bart Teeuwisse (bart.teeuwisse@thecodemill.biz)
    @revision-date April 2002
    @author Mark Aufflick (mark@aufflick.com) page_validation code ported to validate block
    @revision-date 22 April 2008

} {
    sale_price_id:integer,notnull
    product_id:integer,notnull
    sale_price:notnull
    sale_name:html,optional
    sale_begins:array,date
    sale_ends:array,date
    offer_code_needed
    {offer_code {}}
} -validate {
    sale_begins_ok {
	set errmsg [ec_time_widget_validate sale_begins]
    set exception_count 0
    set exception_text ""
	if { $errmsg ne "" } {
	    append exception_text "<li>$errmsg.</li>\n"
	    incr exception_count
	}
    }
    sale_ends_ok { 
	set errmsg [ec_time_widget_validate sale_ends]
	if { $errmsg ne "" } {
	    append exception_text "<li>$errmsg.</li>\n"
	    incr exception_count
	}
    }
}

ad_require_permission [ad_conn package_id] admin

if {![regexp {^[0-9|.]+$} $sale_price ]} {
    ad_return_complaint 1 "The price you entered is not a valid number."
    return
}

if { $offer_code_needed == "yes_supplied" && (![info exists offer_code] || [empty_string_p $offer_code]) } {
    incr exception_count
    append exception_text "<li>You forgot to specify an offer code.</li>\n"
}

if { $exception_count > 0 } {
    ad_return_complaint $exception_count $exception_text
    return
}

# Error checking done

set product_name [ec_product_name $product_id]
set title "Confirm Sale Price for $product_name"
set context [list [list index Products] $title]

# If offer_code_needed is yes_generate, I need to generate a
# offer_code

if { $offer_code_needed == "yes_generate" } {
    set offer_code [ec_generate_random_string 8]
}

set currency [parameter::get -package_id [ec_id] -parameter Currency -default "USD"]

set sale_price_html [ec_pretty_price $sale_price $currency]
set sale_begins_html "[util_AnsiDatetoPrettyDate [ec_date_text sale_begins]] [ec_time_text sale_begins]"
set sale_ends_html "[util_AnsiDatetoPrettyDate [ec_date_text sale_ends]] [ec_time_text sale_ends]"
set offer_code_html [ec_decode $offer_code "" "None Needed" $offer_code]
set export_form_vars_html "[export_form_vars sale_price_id product_id product_name sale_price sale_name offer_code]"
set sale_begins_text [ec_datetime_text sale_begins]
set sale_ends_text [ec_datetime_text sale_ends]

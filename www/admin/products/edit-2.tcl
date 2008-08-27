# /www/[ec_url_concat [ec_url] /admin]/products/edit-2.tcl
ad_page_contract {

  Edit a product.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)

} {

  product_id:integer,notnull
  product_name:notnull
  sku
  one_line_description:html
  detailed_description:html
  color_list
  size_list
  style_list
  email_on_purchase_list
  search_keywords
  url
  price
  no_shipping_avail_p
  present_p
  shipping
  shipping_additional
  weight
  stock_status
  user_class_prices:array,optional
  {categorization:multiple ""}
  available_date:array,date
  upload_file:optional
  upload_file.tmpfile:optional
  template_id
  ec_custom_fields:array,html,optional

} -validate {

    dates_and_integers_are_valid {

      #  If some of custom fields contain dates, they'll end up broken by month,
      #  day and year in separate array elements.  For example, if custom date
      #  field is 'start_date', we'll receive:
      #                 ec_custom_fields(start_date.year)
      #                 ec_custom_fields(start_date.month)
      #                 ec_custom_fields(start_date.day)
      #
      #    We have to assemble them back.

      db_foreach all_date_and_integer_custom_fields {
	select column_type, field_identifier, field_name
	from ec_custom_product_fields
	where column_type in ('date','integer')
	and active_p='t'
      } {
          switch $column_type {

              date {
                  if { [catch  { set ec_custom_fields($field_identifier) [validate_ad_dateentrywidget $field_name ec_custom_fields.$field_identifier [ns_getform] 1]} errmsg] } {
                      ad_complain "$errmsg"
                  }
              }
              integer {
                  if { ![empty_string_p $ec_custom_fields($field_identifier)] } {
                      if { [catch  {validate_integer $field_name $ec_custom_fields($field_identifier)} errmsg] } {
                          ad_complain "$errmsg"
                      }
                  }
              }
          }
      }
  }
}

ad_require_permission [ad_conn package_id] admin

# set_the_usual_form_variables
# product_name, sku, one_line_description, detailed_description, color_list,
# size_list, style_list, email_on_purchase_list, search_keywords, url, price
# no_shipping_avail_p, present_p, available_date, shipping, shipping_additional, weight, stock_status
# and product_id, template_id
# and all active custom fields (except ones that are boolean and weren't filled in)
# and price$user_class_id for all the user classes
# - categorization is a select multiple, so that will be dealt with separately
# - the dates are special (as usual) so they'll have to be "put together"

# break categorization into category_id_list, subcategory_id_list, subsubcategory_id_list
set category_id_list [list]
set subcategory_id_list [list]
set subsubcategory_id_list [list]
foreach categorization $categorization {
    set llength [llength $categorization]
    if {$llength > 0} {
        set category_id [lindex $categorization 0]
	if { [lsearch -exact $category_id_list $category_id] == -1 && ![empty_string_p $category_id]} {
	    lappend category_id_list $category_id
            # ns_log debug edit-2 lappending category_id $category_id 
	}
    }
    if {$llength > 1} {
        set subcategory_id [lindex $categorization 1]
	if {[lsearch -exact $subcategory_id_list $subcategory_id] == -1 && ![empty_string_p $subcategory_id]} {
	    lappend subcategory_id_list $subcategory_id
            # ns_log debug edit-2 lappending subcategory_id $subcategory_id 
	}
    }
    if {$llength > 2} {
        set subsubcategory_id [lindex $categorization 2]
        if {[lsearch -exact $subsubcategory_id_list $subsubcategory_id] == -1 && ![empty_string_p $subsubcategory_id] } {
            lappend subsubcategory_id_list $subsubcategory_id
            # ns_log debug edit-2 lappending subsubcategory_id $subsubcategory_id 
        }
    }
}



# one last manipulation of data is needed: get rid of "http://" if that's all that's
# there for the url (since that was the default value)
if { [string compare $url "http://"] == 0 } {
    set url ""
}

# We now have all values in the correct form

# Get the directory where dirname is stored
set dirname [db_string dirname_select "select dirname from ec_products where product_id=:product_id"]
set full_dirname [file join [ec_data_directory] [ec_product_directory] [ec_product_file_directory $product_id] $dirname]

# if an image file has been specified, upload it into the
# directory that was just created and make a thumbnail (using
# dimensions specified in parameters/whatever.ini)

if { [exists_and_not_null upload_file] } {

    # so that we'll know if it's a gif or a jpg
    set file_extension [file extension $upload_file]

    # tmp file will be deleted when the thread ends
    set tmp_filename ${upload_file.tmpfile} 

    # copies this temp file into a permanent file
#    set perm_filename [file join $full_dirname "product${file_extension}"]
   
    

    # import, copy image & create thumbnails
    # thumbnails are all jpg files
    ns_log Notice $upload_file
    set upload_status [ecommerce::resource::make_product_images \
        -product_id $product_id \
        -tmp_filename ${upload_file.tmpfile} \
        -file_extension $file_extension]

    if { $upload_status == 0 } { 
        ad_return_complaint 1 "<li>There was an error when trying to upload the new product image. Check the server logs if this message persists.</li>"
    }
}

set dirname [ecommerce::resource::dirname -product_id $product_id -product_name $product_name]
set linked_thumbnail [ec_linked_thumbnail_if_it_exists $dirname]

set title "Confirm Product Changes"
set context [list [list index Products] $title]

set currency [parameter::get -package_id [ec_id] -parameter Currency]
set multiple_retailers_p [ad_parameter -package_id [ec_id] MultipleRetailersPerProductP ecommerce]

set categorization_html [ec_category_subcategory_and_subsubcategory_display $category_id_list $subcategory_id_list $subsubcategory_id_list]

    set stock_status_html [ec_message_if_null $stock_status]
if { $multiple_retailers_p } {

    
} else {
    if { ![empty_string_p $stock_status] } {
        set stock_status_html [util_memoize "ad_parameter -package_id [ec_id] \"StockMessage[string toupper $stock_status]\"" [ec_cache_refresh]]
    }
    set user_classes_select_html ""
    db_foreach user_classes_select "select user_class_id, user_class_name from ec_user_classes order by user_class_name" {
        if { [info exists user_class_prices($user_class_id)] } {
            append user_classes_select_html "<tr><td>
	    $user_class_name Price:
	    </td><td>
	    [ec_message_if_null [ec_pretty_price [set user_class_prices($user_class_id)] $currency]]
	    </td></tr>"
        }
    }
}

set regular_price [ec_message_if_null [ec_pretty_price $price $currency]]
set shipping_price [ec_message_if_null [ec_pretty_price $shipping $currency]]
set shipping_additional_price [ec_message_if_null [ec_pretty_price $shipping_additional $currency]]
set one_line_description_html [ec_message_if_null $one_line_description]
set detailed_description_html [ec_display_as_html [ec_message_if_null $detailed_description]]
set search_keywords_html [ec_message_if_null $search_keywords]
set color_list_html [ec_message_if_null $color_list]
set size_list_html [ec_message_if_null $size_list]
set style_list_html [ec_message_if_null $style_list]
set email_on_purchase_list_html [ec_message_if_null $email_on_purchase_list]
set url_html [ec_message_if_null $url]
set no_shipping_avail_p_html [ec_message_if_null [ec_PrettyBoolean [ec_decode $no_shipping_avail_p "t" "f" "f" "t"]]]
set present_p_html [ec_message_if_null [ec_PrettyBoolean $present_p]]
set weight_html "[ec_message_if_null $weight] [ec_decode $weight "" "" [parameter::get -package_id [ec_id] -parameter WeightUnits -default lbs]]"
set template_name_select_html [ec_message_if_null [db_string template_name_select "select template_name from ec_templates where template_id=:template_id" -default ""]]
set available_date_html [ec_message_if_null [util_AnsiDatetoPrettyDate [ec_date_text available_date]]]

set custom_fields_select_html ""
db_foreach custom_fields_select {
  select field_identifier, field_name, column_type
  from ec_custom_product_fields
  where active_p = 't'
} {
    if { [string equal $column_type "date"] || [string equal $column_type "timestamp"] } {
        #CM This is a mess but it seems to work. Basically need to put together the date from the pieces
        #set up a date array to work with.
        array set date "year $ec_custom_fields($field_identifier.year) month $ec_custom_fields($field_identifier.month) day $ec_custom_fields($field_identifier.day)"
        
        #Validate the date - This really should get caught somewhere or put up in the validate section of page contract.
        ec_date_widget_validate date
        #Run the proc that usually runs as part of page contract
        ad_page_contract_filter_proc_date name date
        #Now set the custom field to the ansi date that is set by the above.
        set ec_custom_fields($field_identifier) $date(date)
    }    
    if { [info exists ec_custom_fields($field_identifier)] } {
        append custom_fields_select_html "<tr><td>$field_name</td><td>"
	if { $column_type == "char(1)" } {
        append custom_fields_select_html "[ec_message_if_null [ec_PrettyBoolean "$ec_custom_fields($field_identifier)"]]\n"
	} elseif { $column_type == "date" || $column_type == "timestamp" } {
        append custom_fields_select_html "$ec_custom_fields($field_identifier) to [ec_message_if_null [util_AnsiDatetoPrettyDate "$ec_custom_fields($field_identifier)"]]\n"
	} else {
        append custom_fields_select_html "[ec_display_as_html [ec_message_if_null "$ec_custom_fields($field_identifier)"]]\n"
	}
        append custom_fields_select_html "</td></tr>"
    }
}


set export_form_vars_html "[export_form_vars product_name sku category_id_list subcategory_id_list subsubcategory_id_list one_line_description detailed_description color_list size_list style_list email_on_purchase_list search_keywords url price no_shipping_avail_p present_p shipping shipping_additional weight template_id product_id stock_status]
<input type=hidden name=available_date value=\"[ec_date_text available_date]\">"

# also need to export custom field values
db_foreach custom_fields_export "select field_identifier from ec_custom_product_fields where active_p='t'" {
    if { [info exists ec_custom_fields($field_identifier)] } {
        append export_form_vars_html "<input type=hidden name=\"ec_custom_fields.$field_identifier\" value=\"[ad_quotehtml $ec_custom_fields($field_identifier)]\">\n"
    }
}

foreach user_class_id [db_list user_class_select "select user_class_id from ec_user_classes"] {
    if { [info exists user_class_prices($user_class_id)] } {
        append export_form_vars_html "<input type=hidden name=\"user_class_prices.$user_class_id\" value=\"$user_class_prices($user_class_id)\">\n"
    }
}

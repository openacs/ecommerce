# ecommerce/www/admin/products/add-2.tcl
ad_page_contract {
  Add a product.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id $Id$
  @author ported by Jerry Asher (jerry@theashergroup.com)

} {

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
  ec_custom_fields:array,optional

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

set title "Add A Product continued"
set context [list [list index Products] $title]

ad_require_permission [ad_conn package_id] admin

# set_the_usual_form_variables
# product_name, sku, one_line_description, detailed_description, color_list,
# size_list, style_list, email_on_purchase_list, search_keywords, url, price,
# no_shipping_avail_p, present_p, available_date, shipping, shipping_additional, weight, stock_status
# and all active custom fields (except ones that are boolean and weren't filled in)
# and price$user_class_id for all the user classes
# - categorization is a select multiple, so that will be dealt with separately
# - the dates are special (as usual) so they'll have to be "put together"

# first do error checking

# break categorization into category_id_list, subcategory_id_list, subsubcategory_id_list
set category_id_list [list]
set subcategory_id_list [list]
set subsubcategory_id_list [list]
foreach categorization $categorization {
    if ![catch {set category_id [lindex $categorization 0] } ] {
	if { [lsearch -exact $category_id_list $category_id] == -1 && ![empty_string_p $category_id]} {
	    lappend category_id_list $category_id
	}
    }
    if ![catch {set subcategory_id [lindex $categorization 1] } ] {
	if {[lsearch -exact $subcategory_id_list $subcategory_id] == -1 && ![empty_string_p $subcategory_id]} {
	    lappend subcategory_id_list $subcategory_id
	}
    }
    if ![catch {set subsubcategory_id [lindex $categorization 2] } ] {
	if {[lsearch -exact $subsubcategory_id_list $subsubcategory_id] == -1 && ![empty_string_p $subsubcategory_id] } {
	    lappend subsubcategory_id_list $subsubcategory_id
	}
    }
}



# check the validity of price if the price is not null

if {![info exists price] || ![empty_string_p $price]} {
    if {![regexp {^[0-9|.]+$}  $price  match ] } {
	ad_return_complaint 1 "<li>Please enter a number for price."
	return
    } 
    if {[regexp {^[.]$}  $price match ]} {
	ad_return_complaint 1 "<li>Please enter a number for the price."
	return
    }
}

# one last manipulation of data is needed: get rid of "http://" if that's all that's
# there for the url (since that was the default value)
if { [string compare $url "http://"] == 0 } {
    set url ""
}

# We now have all values in the correct form

# Things to generate:

# 1. generate a product_id
set product_id [db_nextval acs_object_id_seq]

# if an image file has been specified, upload it into the
# directory that was just created and make a thumbnail (using
# dimensions specified in parameters/whatever.ini)

set thumbnail ""

if { [info exists upload_file] && [string length $upload_file] > 4 } {
    
    # tmp file will be deleted when the thread ends
    set tmp_filename ${upload_file.tmpfile}

    # copy image & create thumbnails
    # thumbnails are all jpg files
    
    set dirname [ecommerce::resource::make_product_images \
        -file_extension [file extension $upload_file] \
        -product_id $product_id \
        -product_name $product_name \
                     -tmp_filename ${upload_file.tmpfile} ]

}
if { ![info exists dirname] || [string length $dirname] < 2 } {
    set dirname [ecommerce::resource::dirname -product_id $product_id -product_name $product_name]
}
# TODO: improve, along with admin add product pages
set linked_thumbnail [ecommerce::resource::image_tag -type Thumbnail -product_id $product_id -product_name $product_name]

# Need to let them select template based on category

set export_form_vars_html [export_form_vars product_name sku category_id_list subcategory_id_list subsubcategory_id_list one_line_description detailed_description color_list size_list style_list email_on_purchase_list search_keywords url price no_shipping_avail_p present_p shipping shipping_additional weight linked_thumbnail product_id stock_status dirname]

# also need to export custom field values
db_foreach custom_fields_select "select field_identifier from ec_custom_product_fields where active_p='t'" {
  if { [info exists ec_custom_fields($field_identifier)] } {
    append export_form_vars_html "<input type=hidden name=\"ec_custom_fields.$field_identifier\" value=\"[ad_quotehtml $ec_custom_fields($field_identifier)]\">\n"
  }
}

foreach user_class_id [db_list user_class_select "select user_class_id from ec_user_classes"] {
  append export_form_vars_html "<input type=hidden name=\"user_class_prices.$user_class_id\" value=\"$user_class_prices($user_class_id)\">\n"
}

append export_form_vars_html "<input type=hidden name=available_date value=\"[ec_date_text available_date]\">"
# create the template drop-down list

set template_html [ec_template_widget $category_id_list]



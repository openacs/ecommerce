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
  categorization:multiple
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
# wtem@olywa.net, 2001-03-25
# we are using ec_product.new pl/sql function now instead of old sequence/insert
set product_id [db_nextval acs_object_id_seq]

# 2. generate a directory name (and create the directory) to store pictures
# and other supporting product info

# let's have dirname be the first four letters (lowercase) of the product_name
# followed by the product_id (for uniqueness)
regsub -all {[^a-zA-Z]} $product_name "" letters_in_product_name 
set letters_in_product_name [string tolower $letters_in_product_name]
if [catch {set dirname "[string range $letters_in_product_name 0 3]$product_id"}] {
    #maybe there aren't 4 letters in the product name
    set dirname "$letters_in_product_name$product_id"
}

# Get the directory where dirname is stored
set subdirectory "[ec_data_directory][ec_product_directory][ec_product_file_directory $product_id]"
# if you get errors here
# it may be because you have not completed your technical setup completely
# namely you need to set 
# the EcommerceDataDirectory parameter and ProductDataDirectory parameter
# and create the corresponding directory in the file system
ec_assert_directory $subdirectory

set full_dirname "$subdirectory/$dirname"
ec_assert_directory $full_dirname

# if an image file has been specified, upload it into the
# directory that was just created and make a thumbnail (using
# dimensions specified in parameters/whatever.ini)

if { [info exists upload_file] && ![string compare $upload_file ""] == 0 } {
    
    # this takes the upload_file and sticks its contents into a temporary
    # file (will be deleted when the thread ends)
    set tmp_filename ${upload_file.tmpfile}
    

    # so that we'll know if it's a gif or a jpg
    set file_extension [file extension $upload_file]

    # copies this temp file into a permanent file
    set perm_filename "$full_dirname/product[string tolower $file_extension]"
    ns_cp $tmp_filename $perm_filename
    
    # create thumbnails
    # thumbnails are all jpg files
    
    # set thumbnail dimensions
    set use_both_param_dimensions [parameter::get -parameter ThumbnailSizeOuterlimits]
    set thumbnail_width_is_blank [catch {set thumbnail_width [parameter::get -parameter ThumbnailWidth]} ]
    set thumbnail_height_is_blank [catch {set thumbnail_height [parameter::get -parameter ThumbnailHeight]} ]
    if { $use_both_param_dimensions } {
        set convert_dimensions "${thumbnail_width}x${thumbnail_height}>"
    } else {
        if  { $thumbnail_width_is_blank } {
	    if  { $thumbnail_height_is_blank } {
	        set convert_dimensions "100x10000"
	    } else {
	        set convert_dimensions "10000x${thumbnail_height}"
	    }
        } else {
	    set convert_dimensions "${thumbnail_width}x10000"
        }
    }

    set system_url [parameter::get -package_id [ad_acs_kernel_id] -parameter SystemURL]
    set system_name [parameter::get -package_id [ad_acs_kernel_id] -parameter SystemName]
    set image_comment "from $system_url $system_name"

    set perm_thumbnail_filename "$full_dirname/product-thumbnail.jpg"

    set convert [ec_convert_path]
    if {![string equal "" $convert] && [file exists $convert]} {
        if [catch {exec $convert -geometry $convert_dimensions -comment \"$image_comment\" $perm_filename $perm_thumbnail_filename} errmsg ] {
            ad_return_complaint 1 "
                I am sorry, an error occurred converting the picture.  $errmsg
            "
        }
    } else {
        ad_return_complaint 1 {
            I am sorry, I could not find ImageMagick's <b>convert</b> utility for
            image thumbnail creation.  Please reconfigure this subsystem before
            uploading pictures
        }
    }
}

set linked_thumbnail [ec_linked_thumbnail_if_it_exists $dirname]

# Need to let them select template based on category

doc_body_append "[ad_admin_header "Add a Product, Continued"]

<h2>Add a Product, Continued</h2>

[ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Products"] "Add Product"]

<hr>
<form method=post action=add-3>
[export_form_vars product_name sku category_id_list subcategory_id_list subsubcategory_id_list one_line_description detailed_description color_list size_list style_list email_on_purchase_list search_keywords url price no_shipping_avail_p present_p shipping shipping_additional weight linked_thumbnail product_id dirname stock_status]
<input type=hidden name=available_date value=\"$available_date(date)\">
"

# also need to export custom field values
db_foreach custom_fields_select "select field_identifier from ec_custom_product_fields where active_p='t'" {
  if { [info exists ec_custom_fields($field_identifier)] } {
    doc_body_append "<input type=hidden name=\"ec_custom_fields.$field_identifier\" value=\"[ad_quotehtml $ec_custom_fields($field_identifier)]\">\n"
  }
}

foreach user_class_id [db_list user_class_select "select user_class_id from ec_user_classes"] {
  doc_body_append "<input type=hidden name=\"user_class_prices.$user_class_id\" value=\"$user_class_prices($user_class_id)\">\n"
}

# create the template drop-down list

doc_body_append "

<h3>Select a template to use when displaying this product.</h3>

<p>

If none is
selected, the product will be displayed with the system default template.<br>
<blockquote>
[ec_template_widget $category_id_list]
</blockquote>
<p>

<center>
<input type=submit value=\"Submit\">
</center>
</form>

[ad_admin_footer]
"

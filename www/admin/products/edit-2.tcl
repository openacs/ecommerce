# /www/[ec_url_concat [ec_url] /admin]/products/edit-2.tcl
ad_page_contract {

  Edit a product.

  @author Eve Andersson (eveander@arsdigita.com)
  @creation-date Summer 1999
  @cvs-id edit-2.tcl,v 3.4.2.5 2000/08/22 02:11:41 tzumainn Exp
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

#  ns_log debug edit-2 B category_id_list $category_id_list
#  ns_log debug edit-2 B subcategory_id_list $subcategory_id_list
#  ns_log debug edit-2 B subsubcategory_id_list $subsubcategory_id_list

# Now deal with dates.
# The column available_date is known to be a date.
# Also, some of the custom fields may be dates.

#page_validation {
  #ec_date_widget_validate available_date
#} {
  #set date_field_identifiers [db_list custom_date_fields_select "select field_identifier from ec_custom_product_fields where column_type='date' and active_p='t'"]
  #foreach field_identifier $date_field_identifiers {
    #array set date {year ec_custom_fields($field_identifier.year) month ec_custom_fields($field_identifier.month) ec_custom_fields($field_identifier.day)}
   # ec_date_widget_validate date
  #}
#}




# one last manipulation of data is needed: get rid of "http://" if that's all that's
# there for the url (since that was the default value)
if { [string compare $url "http://"] == 0 } {
    set url ""
}

# We now have all values in the correct form

# Get the directory where dirname is stored
set dirname [db_string dirname_select "select dirname from ec_products where product_id=:product_id"]
set subdirectory [ec_product_file_directory $product_id]
set full_dirname "[ec_data_directory][ec_product_directory]$subdirectory/$dirname"

# if an image file has been specified, upload it into the
# directory that was just created and make a thumbnail (using
# dimensions specified in parameters/whatever.ini)

if { [exists_and_not_null upload_file] } {
    
    # this takes the upload_file and sticks its contents into a temporary
    # file (will be deleted when the thread ends)
    set tmp_filename ${upload_file.tmpfile}
    
    # so that we'll know if it's a gif or a jpg
    set file_extension [file extension $upload_file]

    # copies this temp file into a permanent file
    set perm_filename "$full_dirname/product$file_extension"
    ns_cp $tmp_filename $perm_filename
    
    # create thumbnails
    # thumbnails are all jpg files
    
    # set thumbnail dimensions
    if [catch {set thumbnail_width [util_memoize {ad_parameter -package_id [ec_id] ThumbnailWidth ecommerce} [ec_cache_refresh]]} ] {
	if [catch {set thumbnail_height [util_memoize {ad_parameter -package_id [ec_id] ThumbnailHeight ecommerce} [ec_cache_refresh]]} ] {
	    set convert_dimensions "100x10000"
	} else {
	    set convert_dimensions "10000x$thumbnail_height"
	}
    } else {
	set convert_dimensions "${thumbnail_width}x10000"
    }

    set perm_thumbnail_filename "$full_dirname/product-thumbnail.jpg"

    set convert [ec_convert_path]
    if {![string equal "" $convert] && [file exists $convert]} {
        if [catch {exec $convert -geometry $convert_dimensions $perm_filename $perm_thumbnail_filename} errmsg ] {
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

doc_body_append "[ad_admin_header "Confirm Product Changes"]

<h2>Confirm Product Changes</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index" "Products"] [list "one?[export_url_vars product_id]" $product_name] "Edit Product"]
<hr>
<h3>Please confirm that the information below is correct:</h3>
"

set currency [util_memoize {ad_parameter -package_id [ec_id] Currency ecommerce} [ec_cache_refresh]]
set multiple_retailers_p [util_memoize {ad_parameter -package_id [ec_id] MultipleRetailersPerProductP ecommerce} [ec_cache_refresh]]

doc_body_append "<form method=post action=edit-3>
<center>
<input type=submit value=\"Confirm\">
</center>
<blockquote>
$linked_thumbnail
<table noborder>
<tr>
<td>
Product Name:
</td>
<td>
$product_name
</td>
</tr>
<tr>
<td>
SKU
</td>
<td>
$sku
</td>
</tr>
<tr>
<td>
Categorization:
</td>
<td>
[ec_category_subcategory_and_subsubcategory_display $category_id_list $subcategory_id_list $subsubcategory_id_list]
</td>
</tr>
"
if { !$multiple_retailers_p } {
    doc_body_append "<tr>
    <td>
    Stock Status:
    </td>
    <td>
    "
    if { ![empty_string_p $stock_status] } {
	doc_body_append [util_memoize "ad_parameter -package_id [ec_id] \"StockMessage[string toupper $stock_status]\"" [ec_cache_refresh]]
    } else {
	doc_body_append [ec_message_if_null $stock_status]
    }

    doc_body_append "</td>
    </tr>
    "
}
doc_body_append "<tr>
<td>
One-Line Description:
</td>
<td>
[ec_message_if_null $one_line_description]
</td>
</tr>
<tr>
<td>
Additional Descriptive Text:
</td>
<td>
[ec_display_as_html [ec_message_if_null $detailed_description]]
</td>
</tr>
<tr>
<td>
Search Keywords:
</td>
<td>
[ec_message_if_null $search_keywords]
</td>
</tr>
<tr>
<td>
Color Choices:
</td>
<td>
[ec_message_if_null $color_list]
</td>
</tr>
<tr>
<td>
Size Choices:
</td>
<td>
[ec_message_if_null $size_list]
</td>
</tr>
<tr>
<td>
Style Choices:
</td>
<td>
[ec_message_if_null $style_list]
</td>
</tr>
<tr>
<td>
Email on Purchase:
</td>
<td>
[ec_message_if_null $email_on_purchase_list]
</td>
</tr>
<tr>
<td>
URL:
</td>
<td>
[ec_message_if_null $url]
</td>
</tr>
"
if { !$multiple_retailers_p } {
    doc_body_append "<tr>
    <td>
    Regular Price:
    </td>
    <td>
    [ec_message_if_null [ec_pretty_price $price $currency]]
    </td>
    </tr>
    "
}
doc_body_append "<tr>
<td>
Is this product shippable?
</td>
<td>
[ec_message_if_null [ec_PrettyBoolean [ec_decode $no_shipping_avail_p "t" "f" "f" "t"]]]
</td>
</tr>
<tr>
<td>
Display this product when user does a search?
</td>
<td>
[ec_message_if_null [ec_PrettyBoolean $present_p]]
</td>
</tr>
"
if { !$multiple_retailers_p } {
    doc_body_append "<tr>
    <td>
    Shipping Price
    </td>
    <td>
    [ec_message_if_null [ec_pretty_price $shipping $currency]]
    </td>
    </tr>
    <tr>
    <td>
    Shipping - Additional
    </td>
    <td>
    [ec_message_if_null [ec_pretty_price $shipping_additional $currency]]
    </td>
    </tr>
    "
}
doc_body_append "<tr>
<td>
Weight
</td>
<td>
[ec_message_if_null $weight] [ec_decode $weight "" "" [util_memoize {ad_parameter -package_id [ec_id] WeightUnits ecommerce} [ec_cache_refresh]]]
</td>
</tr>
"
if { !$multiple_retailers_p } {
    db_foreach user_classes_select "select user_class_id, user_class_name from ec_user_classes order by user_class_name" {
	if { [info exists user_class_prices($user_class_id)] } {
	    doc_body_append "
	    <tr>
	    <td>
	    $user_class_name Price:
	</td>
	    <td>
	    [ec_message_if_null [ec_pretty_price [set user_class_prices($user_class_id)] $currency]]
	    </td>
	    </tr>
	    "
	}
    }
}

db_foreach custom_fields_select {
  select field_identifier, field_name, column_type
  from ec_custom_product_fields
  where active_p = 't'
} {
    if { [info exists ec_custom_fields($field_identifier)] } {
	doc_body_append "
	<tr>
	<td>
	$field_name
	</td>
	<td>
	"
	if { $column_type == "char(1)" } {
	  doc_body_append "[ec_message_if_null [ec_PrettyBoolean "$ec_custom_fields($field_identifier)"]]\n"
	} elseif { $column_type == "date" } {
	  doc_body_append "[ec_message_if_null [util_AnsiDatetoPrettyDate "$ec_custom_fields($field_identifier)"]]\n"
	} else {
	  doc_body_append "[ec_display_as_html [ec_message_if_null "$ec_custom_fields($field_identifier)"]]\n"
	}
	doc_body_append "</td>
	</tr>
	"
    }
}


doc_body_append "<tr>
<td>
Template
</td>
<td>
[ec_message_if_null [db_string template_name_select "select template_name from ec_templates where template_id=:template_id" -default ""]]
</td>
</tr>
<tr>
<td>
Available Date
</td>
<td>
[ec_message_if_null [util_AnsiDatetoPrettyDate [ec_date_text available_date]]]
</td>
</tr>
</table>
</blockquote>
<p>

[export_form_vars product_name sku category_id_list subcategory_id_list subsubcategory_id_list one_line_description detailed_description color_list size_list style_list email_on_purchase_list search_keywords url price no_shipping_avail_p present_p shipping shipping_additional weight template_id product_id stock_status]
<input type=hidden name=available_date value=\"[ec_date_text available_date]\">
"

# also need to export custom field values
db_foreach custom_fields_select "select field_identifier from ec_custom_product_fields where active_p='t'" {
  if { [info exists ec_custom_fields($field_identifier)] } {
    doc_body_append "<input type=hidden name=\"ec_custom_fields.$field_identifier\" value=\"[ad_quotehtml $ec_custom_fields($field_identifier)]\">\n"
  }
}

foreach user_class_id [db_list user_class_select "select user_class_id from ec_user_classes"] {
  if { [info exists user_class_prices($user_class_id)] } {
    doc_body_append "<input type=hidden name=\"user_class_prices.$user_class_id\" value=\"$user_class_prices($user_class_id)\">\n"
  }
}

doc_body_append "<center>
<input type=submit value=\"Confirm\">
</center>
</form>

[ad_admin_footer]
"

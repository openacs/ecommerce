#  www/[ec_url_concat [ec_url] /admin]/products/upload-2.tcl
ad_page_contract {

  @author
  @creation-date
  @cvs-id upload-2.tcl,v 3.1.2.4 2000/10/27 23:17:11 kevin Exp
  @author ported by Jerry Asher (jerry@theashergroup.com)
} {
  csv_file
  csv_file.tmpfile:tmpfile
}

ad_require_permission [ad_conn package_id] admin

if { [empty_string_p $csv_file] } {
    ad_return_error "Missing CSV File" "You must input the name of the .csv file on your local hard drive."
    return
}

set user_id [ad_get_user_id]
set ip [ns_conn peeraddr]

doc_body_append "[ad_admin_header "Uploading Products"]

<h2>Uploading Products</h2>

[ad_admin_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] "Uploading Products"]

<hr>

<blockquote>
"

set unix_file_name ${csv_file.tmpfile}


if { ![file readable $unix_file_name] } {
    doc_body_append "Cannot read file $unix_file_name"
    return
}

set csvfp [open $unix_file_name]

set count 0
set success_count 0
while { [ns_getcsv $csvfp elements] != -1 } {
    incr count
    if { $count == 1 } {
	# first time through, we grab the number of columns and their names
	set number_of_columns [llength $elements]
	set columns $elements
	# These 2 lines added 1999-08-08
	set product_id_column [lsearch -exact $columns "product_id"]
	set product_name_column [lsearch -exact $columns "product_name"]
    } else {
	# this line is a product

	# All this directory stuff added 1999-08-08
	# To be consistent with directory-creation that occurs when a
	# product is added, dirname will be the first four letters 
	# (lowercase) of the product_name followed by the product_id
	# (for uniqueness)
	regsub -all {[^a-zA-Z]} [lindex $elements $product_name_column] "" letters_in_product_name 
	set letters_in_product_name [string tolower $letters_in_product_name]
	if [catch {set dirname "[string range $letters_in_product_name 0 3][lindex $elements $product_id_column]"}] {
	    #maybe there aren't 4 letters in the product name
	    set dirname "$letters_in_product_name[lindex $elements $product_id_column]"
	}
	
	set columns_sql "insert into ec_products (creation_date, available_date, dirname, last_modified, last_modifying_user, modified_ip_address "
	set values_sql " values (sysdate, sysdate, :dirname, sysdate, :user_id, :ip "
	for { set i 0 } { $i < $number_of_columns } { incr i } {
	  append columns_sql ", [lindex $columns $i]"
	  set var_name "val_$i"
	  set $var_name [lindex $elements $i]
	  append values_sql ", :$var_name"
	}
	set sql "$columns_sql ) $values_sql )"

	# we have to also write a row into ec_custom_product_field_values
	# for consistency with add*.tcl (added 1999-08-08)
	db_transaction {
	
	  if { [catch {db_dml product_insert $sql} errmsg] } {
	    doc_body_append "<font color=red>FAILURE!</font> SQL: $sql<br>$number_of_columns<br>$product_id_column<br>$product_name_column<br>\n"
	  } else {
	    incr success_count
	    if { [catch {db_dml custom_product_field_insert "insert into ec_custom_product_field_values (product_id, last_modified, last_modifying_user, modified_ip_address) values (:val_$product_id_column, sysdate, :user_id, :peeraddr)" } errmsg] } {
		doc_body_append "<font color=red>FAILURE!</font> Insert into ec_custom_product_field_values failed for product_id=[set val_$product_id_column]<br>\n"
	    }
	    }

	    # Get the directory where dirname is stored
	    set subdirectory "[ec_data_directory][ec_product_directory][ec_product_file_directory [lindex $elements $product_id_column]]"
	    ec_assert_directory $subdirectory

	    set full_dirname "$subdirectory/$dirname"
	    ec_assert_directory $full_dirname
	}
    }
}

if { $success_count == 1 } {
    set product_string "product"
} else {
    set product_string "products"
}

doc_body_append "</blockquote>

<p>Successfully loaded $success_count $product_string out of [ec_decode $count "0" "0" [expr $count -1]].

[ad_admin_footer]
"

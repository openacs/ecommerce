#  www/[ec_url_concat [ec_url] /admin]/products/extras-upload-2.tcl
ad_page_contract {
  This file updates ec_custom_product_field_values (as opposed to inserting
  new rows) because upload*.tcl (which are to be run before extras-upload*.tcl)
  insert rows into ec_custom_product_field_values (with everything empty except
  product_id and the audit columns) when they insert the rows into ec_products
  (for consistency with add*.tcl).

  @author
  @creation-date
  @cvs-id $Id$
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

doc_body_append "[ad_admin_header "Uploading Extras"]

<h2>Uploading Extras</h2>

[ad_context_bar [list "../" "Ecommerce([ec_system_name])"] [list "index.tcl" "Products"] "Uploading Extras"]

<hr>

"

set unix_file_name ${csv_file.tmpfile}

if { ![file readable $unix_file_name] } {
    doc_body_append "Cannot read file $unix_file_name"
    return
}

doc_body_append "<pre>
"

set csvfp [open $unix_file_name]

set count 0
while { [ec_gets_char_delimited_line $csvfp elements] != -1 } {
    incr count
    if { $count == 1 } {
	# first time thru, we grab the number of columns and their names
	set number_of_columns [llength $elements]
	set columns $elements
	set product_id_column [lsearch -exact $columns "product_id"]
    } else {
	# this line is a product
# (this file used to insert rows into ec_custom_product_field_values, but
# now that is done in upload-2.tcl, so we need to update instead)
# 	set columns_sql "insert into ec_custom_product_field_values (last_modified, last_modifying_user, modified_ip_address "
# 	set values_sql " values (sysdate, $user_id, '$ip' "
# 	for { set i 0 } { $i < $number_of_columns } { incr i } {
# 	    append columns_sql ", [lindex $columns $i]"
# 	    append values_sql ", '[DoubleApos [lindex $elements $i]]'"
# 	}
# 	set sql "$columns_sql ) $values_sql )"

	set sql "update ec_custom_product_field_values set last_modified=sysdate, last_modifying_user=:user_id, modified_ip_address=:ip"

	for { set i 0 } { $i < $number_of_columns } { incr i } {
	  set var_name "var_$i"
	  set $var_name [lindex $elements $i]
	  if { $i != $product_id_column } {
	    append sql ", [lindex $columns $i]=:$var_name"
	  }
	}
	append sql " where product_id=:var_$product_id_column"

	if { [catch {db_dml product_update $sql} errmsg] } {
	    append bad_products_sql "$sql\n"
	    doc_body_append "<font color=red>FAILURE!</font> SQL: $sql<br>\n"
	} else {
	    doc_body_append "Success!<br>\n"
	}
    }
}

doc_body_append "</pre>
<p>Done loading [ec_decode $count "0" "0" [expr $count -1]] products extras!

<p>

(Note: \"success\" doesn't actually mean that the information was uploaded; it
just means that Oracle didn't choke on it (since updates to tables are considered
successes even if 0 rows are updated).  If you need reassurance, spot check some of the individual products.)
[ad_admin_footer]
"


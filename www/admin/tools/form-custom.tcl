# form-custom.tcl,v 3.0 2000/02/06 03:54:42 ron Exp
#
# Takes the data generated from ad_table_sort_form function 
# and inserts into the user_custom table
#
# on succes it does an ns_returnredirect to return_url
#
# davis@xarg.net 20000105

set internals {item item_group return_url item_original delete_the_set}
ad_page_variables {item item_group return_url {item_original {}} {delete_the_set 0}}

set db [ns_db gethandle]
set user_id [ad_conn user_id] 
auth::require_login    
set item_type {slider_custom}
set value_type {keyval}

if {$delete_the_set && ![empty_string_p $item]} {
    util_dbq {item item_type value_type item_group}
    if {[catch {ns_db dml $db "delete user_custom
          where user_id = $user_id and item = $DBQitem and item_group = $DBQitem_group
            and item_type = $DBQitem_type"} errmsg]} {
        ad_return_complaint 1 "<li>I was unable to delete the defaults.  The database said <pre>$errmsg</pre>\n"
        ad_script_abort
    }
    ad_returnredirect "$return_url"
    ad_script_abort
}

        
   
if {[empty_string_p $item]} {
    ad_return_complaint 1 "<li>You did not specify a name for this default set."
    ad_script_abort
}

set form [ns_getform]
for {set i 0} { $i < [ns_set size $form]} {incr i} {
    if {[lsearch $internals [ns_set key $form $i]] < 0} { 
        lappend data [list [ns_set key $form $i] [ns_set value $form $i]]
    }
}


if {[empty_string_p $data]} {
    ad_return_complaint 1 "<li>You did not specify any default data."
    ad_script_abort
}

util_dbq {item item_original item_type value_type item_group}
with_transaction $db {
    ns_db dml $db "delete user_custom
      where user_id = $user_id and item = $DBQitem_original and item_group = $DBQitem_group
        and item_type = $DBQitem_type"

    ns_ora clob_dml $db "insert into user_custom (user_id, item, item_group, item_type, value_type, value)
      values ($user_id, $DBQitem, $DBQitem_group, $DBQitem_type, 'list', empty_clob())
      returning value into :1" $data
} {
    ad_return_complaint 1 "<li>I was unable to insert your defaults. The database said <pre>$errmsg</pre>\n"
    ad_script_abort
}

ad_returnredirect "$return_url"

# /tcl/ad-audit-trail.tcl

ad_library {

    Procedures uses to view the audit trails documented in /www/doc/audit

    two procs helpful for building pages that show audit history for a
    set of id's in a table between specific dates

    @author Jesse Koontz (jkoontz@arsdigita.com)
    @author Trace Adams (teadams@arsdigita.com)
    @author Jerry Asher (jerry@hollyjerry.org)
    @creation-date August 1999
    @cvs-id ad-audit-trail.tcl,v 3.1.2.9 2000/08/20 10:32:42 seb Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)

}

ad_proc ec_audit_trail {
    {
        -bind {}
    }
    id_list audit_table_name main_table_name id_column_list
    { columns_not_reported ""}
    {start_date ""}
    {end_date ""}
    {restore_url ""}
} {

        Returns an HTML fragment showing changes to one row in the
        OLTP system between the times start_date and end_date
        (YYYY-MM-DD HH24:MI:SS).  There will be one section for each
        row in the audit table and a single section for the occurrence
        of id (must be unique) in main_table, the entire affair sorted
        by time (descending). If a restore_url is provided, a link
        will appear next to each non-delete section to the restore url
        with the current rowid and ec_audit_trail arguments.

        ARGUMENT
        audit_table_name - table that holds the audit records
        main_table_name - table that holds the main record
        id_column_list - list of column names representing the unique
           key in audit_table_name and main_table_name
        id_list - list of ids of the unique record you are auditing
        columns_not_reported - tcl list of names in audit_table_name
        and main_table that you don't want displayed
        start_date - ANSI standard time to begin viewing records
        end_date - ANSI standard time to stop viewing records

        restore_url - URL of a tcl page that would restore a given
        record to the main table. Form variables for the page: id
        id_column main_table_name audit_table_name and rowi
} {
ns_log debug eatp end_date $end_date
    # These values will be part of an audit entry description
    # and do not need to be reported seperately
    lappend columns_not_reported modifying_user_name
    lappend columns_not_reported last_modifying_user
    lappend columns_not_reported last_modified
    lappend columns_not_reported modified_ip_address
    lappend columns_not_reported delete_p
    lappend columns_not_reported rowid

    # HTML string to be returned at the end of the proc
    set return_string ""

    # declare the two ns_sets for bind variables before we start building
    # up our where clause
    if { ![empty_string_p $bind] } {
        set main_bind_vars [ns_set copy $bind]
        set audit_bind_vars [ns_set copy $bind]
    } else {
        set main_bind_vars [ns_set create]
        set audit_bind_vars [ns_set create]
    }

    # The date restrictions should only be added if start_date or end_date
    # is not empty
    set date_clause ""
    set main_table_date_clause ""
    if { ![empty_string_p $end_date] } {
        ns_set put $main_bind_vars "end_date" $end_date
        ns_set put $audit_bind_vars "end_date" $end_date
        set table_name     "$audit_table_name.last_modified"
        set date_val       "to_date(:end_date,'YYYY-MM-DD HH24:MI:SS')"
        append date_clause "\nand $table_name < $date_val"
        
        set table_name     "$main_table_name.last_modified"
        append main_table_date_clause "\nand $table_name < $date_val"
    }
    if { ![empty_string_p $start_date] } {
        ns_set put $main_bind_vars "start_date" $start_date
        ns_set put $audit_bind_vars "start_date" $start_date
        set table_name     "$audit_table_name.last_modified"
        set date_val       "to_date(:start_date,'YYYY-MM-DD HH24:MI:SS')"
        append date_clause "\nand table_name > $date_val"
        
        set table_name     "$main_table_name.last_modified"
        append main_table_date_clause "\nand table_name > $date_val"
    }

    # Generate main and audit table restrictions for
    # the ids in the id columns
    set main_table_id_clause ""
    set audit_table_id_clause ""
    set count 0

    # check that the ids are not going to cause a problem
    foreach id $id_list {
        set id_column [lindex $id_column_list $count]
        incr count

        set main_column_name \
                [ec_audit_generate_column_name \
                $main_table_name $id_column]
        set audit_column_name \
                [ec_audit_generate_column_name \
                $audit_table_name $id_column]
        if {[string compare $main_column_name $audit_column_name] == 0} {
            # shorten the main_column_name
            #set main_column_name [string range $main_column_name 0 28]
        }

        # Add the columns to the list of bind variables
        ns_set put $main_bind_vars $main_column_name $id
        ns_set put $audit_bind_vars $audit_column_name $id

        #append main_table_id_clause \
        #"and main_table_name=$main_table_name"
        #append main_table_id_clause \
        #"and id_column = $id_column"
        #append main_table_id_clause \
        #"and main_column_name = $main_column_name"
        append main_table_id_clause "
            and $main_table_name.$id_column = :$main_column_name "
        append audit_table_id_clause "
            and $audit_table_name.$id_column = :$audit_column_name"

    }

    # Get the entries in the audit table

    set sql "
    select $audit_table_name.*,
           $audit_table_name.rowid,
           to_char($audit_table_name.last_modified,
                   'Mon DD, YYYY HH12:MI AM') as last_modified,
           users.first_names || ' ' || users.last_name
                   as modifying_user_name
      from $audit_table_name, cc_users users
     where users.user_id = $audit_table_name.last_modifying_user $audit_table_id_clause $date_clause
  order by $audit_table_name.last_modified asc
    "

    # ns_log Notice "AUDIT SQL: $sql"

    # The first record displayed may not represent an insert if
    # start_date is not empty. So display the first record as an
    # update$audit_table_name.$id_column, if start_date is not empty.
        
    if { ![empty_string_p $start_date] } {
        # Not all records will be displayed, so first record may not be
        # an insert.
        set audit_count 1
    } else {
        # All records are being displayed so first record is an insert
        set audit_count 0
    }

    # used to keep track of previous record's data so that only updated
    # information is displayed.
    set old_selection [ns_set create old_selection]

    # ec_audit_process_rows looks for ns_set called bind_vars. Set it
    #  to the bind variables for the audit trail
    # We use db_with_handle because we really have no way of knowing
    #  what is in the rows we're getting back. ec_audit_process_row
    #  iterates over selection
    set loop 0
    db_with_handle db {
        set selection [ns_ora select $db -bind $audit_bind_vars $sql]
        while { [ns_db getrow $db $selection] } {
            ec_audit_process_row
            append return_string $audit_entry
            incr loop
        }
    }
    ns_set free $audit_bind_vars

    # get the current records
    set sql "
    select $main_table_name.*,
           users.first_names || ' ' || users.last_name
               as modifying_user_name,
           to_char($main_table_name.last_modified,
               'Mon DD, YYYY HH12:MI AM') as last_modified
      from $main_table_name, cc_users users
     where users.user_id = $main_table_name.last_modifying_user $main_table_id_clause $main_table_date_clause
  order by $main_table_name.last_modified asc"

    # tell ec_audit_process_row that this is not a deleted row
    set delete_p "f"

    # We use db_with_handle because we really have no way of knowing
    #  what is in the rows we're getting back. ec_audit_process_row
    #  iterates over selection
    db_with_handle db {
        set selection [ns_ora select $db -bind $main_bind_vars $sql]
        while { [ns_db getrow $db $selection] } {
            ec_audit_process_row
            append return_string $audit_entry
        }
    }
    ns_set free $main_bind_vars
    return $return_string
}

ad_proc ec_audit_process_row { } {
     internal proc for ec_audit_trail
     Sets audit_entry to the HTML fragement representing one line
     from the audit table or main table.
     First it identifies whether the row was a delete, update, or insert
     Second, it builds a table of values that changed from the last row
} {

    uplevel {

        set_variables_after_query

        # Loop through each column key and value in the selection
        set selection_counter_i 0
        set modification_count 0
        set selection_size [ns_set size $selection]

        set u [ec_admin_present_user \
                $last_modifying_user $modifying_user_name]
        if { $delete_p == "t" } {
            # Entry in the audit table is for a deleted row
            # Set the audit entry to a single line
            set audit_entry "<h4>Delete on $last_modified by $u
              </a> ($modified_ip_address)</h4>"

            # Reset the audit value records
            set audit_count 0
            set old_selection [ns_set create old_selection]

        } else {
            if { $audit_count == 0 } {
                # No previous audit entry for this ID key
                set audit_entry "<h4>Insert on $last_modified by $u
                  </a> ($modified_ip_address)</h4><table>"
            } else {
                # This audit entry represents an update to the main row
                set audit_entry "<h4>Update on $last_modified by $u
                  </a> ($modified_ip_address)</h4><table>"
            }

            while { $selection_counter_i < $selection_size } {
                set column [ns_set key $selection $selection_counter_i]
                set value   [ns_set value $selection $selection_counter_i]
                if {[lsearch -glob $columns_not_reported $column] == -1} {
                    if { $audit_count > 0 } {
                        if {$value != \
                                [ns_set get $old_selection $column]} {
                            # report if the value changed
                            if { [empty_string_p \
                                    [ns_set \
                                    get $old_selection $column]]} {
                                append audit_entry "
                                <tr>
                                <td  valign=top>
                                  Added $column:
                                </td>
                                <td>
                                  [ns_quotehtml $value]
                                </td>
                                </tr>
                                "
                            } else {
                                append audit_entry "
                                <tr>
                                <td  valign=top>
                                  Modified $column:
                                </td>
                                <td>
                                  [ns_quotehtml $value]
                                </td>
                                </tr>
                                "
                            }
                            incr modification_count
                        }

                    } elseif { ![empty_string_p $value] }  {
                        # report initial value if it is not blank
                        append audit_entry "
                        <tr>
                        <td  valign=top>
                          Added $column:
                        </td>
                        <td>
                          [ns_quotehtml $value]
                        </td>
                        </tr>
                        "
                    }
                }
                ns_set update $old_selection $column $value
                incr selection_counter_i
            }
            if { $audit_count > 0 && $modification_count == 0 } {
                # if it is the same person on the same day, we don't care
                if {[string compare $last_modified [ns_set get $old_selection last_modified]] != 0 || [string compare $last_modifying_user [ns_set get $old_selection last_modifying_user]] != 0  } {
                    append audit_entry "
                    <tr>
                    <td colspan=2>
                      Recorded again with no modifications
                    </td>
                    </tr>
                    "
                } else {
                    set audit_entry ""
                }
            }
            append audit_entry "</table>"
            if { ![empty_string_p $restore_url] } {
                set exports [export_url_vars id id_column \
                        main_table_name audit_table_name rowid]
                append audit_entry "
                Restore <a href=\"$restore_url?$exports\">this record</a>
                to the main table.
                "
            }
            incr audit_count
        }
    }
}

proc_doc ec_audit_delete_row { id_list id_column_list audit_table_name } {
    Inserts an entry to the audit table to log a delete. Each id is
    inserted into its id_column as well as user_id, IP address, and date.
} {

    # VARIABLES
    # audit_table_name - table that holds the audit records
    # id_column_list - column names of the primary key(s) in
    #      audit_table_name
    # id_list -  ids of the record you are processing

    if {[string equal "" $id_column_list]} {
        set id_column_join ""
        set id_column_bind_join ""
    } else {
        set id_column_join [join $id_column_list ", "],
        set id_column_bind_join ":[join $id_column_list ", :"],"
    }

    # Create the bind variables
    set bind_vars [ns_set create]

    for { set i 0 } { $i < [llength $id_column_list] } { incr i } {
        ns_set put $bind_vars \
                [lindex $id_column_list $i] [lindex $id_list $i]
    }
    # Add the final audit columns to the ns_set
    ns_set put $bind_vars last_modifying_user [ad_get_user_id]
    ns_set put $bind_vars modified_ip_address [ns_conn peeraddr]
    ns_set put $bind_vars delete_p t

    db_dml audit_table_insert "
    insert into $audit_table_name
           ($id_column_join last_modified,
           last_modifying_user, modified_ip_address, delete_p)
    values ($id_column_bind_join sysdate,
            :last_modifying_user, :modified_ip_address, :delete_p)
    " -bind $bind_vars

    ns_set free $bind_vars

}

proc_doc ec_audit_trail_for_table {
    main_table_name
    audit_table_name
    id_column
    {start_date ""}
    {end_date ""}
    {audit_url ""}
    {restore_url ""}
} {

    Returns the audit trail for each id from the id_column for updates
and deletes from main_table_name and audit_table_name that occured
between start_date and end_date. If start_date is blank, then it is
assumed to be when the table was created, if end_date is blank then it
is assumed to be the current time. The audit_url, if it exists, will
be given the calling arguments for ec_audit_trail.

} {

    # Text being returned by the proc
    set return_html ""

    # Build a sql string to only return records which where last modified
    # between the start date and end date
    set bind_vars [ns_set create]
    set date_clause_list [list]
    if { ![empty_string_p $end_date] } {
        ns_set put $bind_vars end_date $end_date
        set date_val "to_date(:end_date,'YYYY-MM-DD HH24:MI:SS')"
        lappend date_clause_list "last_modified < $date_val"
    }
    if { ![empty_string_p $start_date] } {
        ns_set put $bind_vars start_date $start_date
        set date_val "to_date(:start_date,'YYYY-MM-DD HH24:MI:SS')"
        lappend date_clause_list "last_modified > $date_val"
    }
ns_log debug eatp date_clause_list $date_clause_list
    # Generate a list of ids for records that where modified in the time
    # between start_date and end_date.
    set id_list [db_list audit_table_column_select "
        select distinct $id_column
          from $main_table_name
         where [join $date_clause_list "\nand "]
    "]
    # Don't free the ns_set as we reuse it down below
ns_log debug eatp id_list:[llength $id_list] $id_list
    # Display the grouped modifications to each id in id_list
    foreach id $id_list {
        # Set the HTML link tags to a page which displays the full
        # audit history.
        if { ![empty_string_p $audit_url] } {
            set exports [export_url_vars id id_column \
                    main_table_name audit_table_name]
            set id_href "<a href=\"$audit_url?$exports\">"
            set id_href_close "</a>"
        } else {
            set id_href ""
            set id_href_close ""
        }


        set cell [ec_audit_trail $id \
                $audit_table_name $main_table_name $id_column "" \
                $start_date $end_date]
        append return_html "
        <h4>$id_column Is $id_href $id $id_href_close</h4>
        <blockquote>
        <table border=3><tr><td>
        $cell
        </td></tr></table>
        </blockquote>
        "
    }

    # We will now repeate the process to display the modifications
    # that took place between start_date and end_date but occurred on
    # records that have been deleted.

    # Add a constraint to view only deleted ids and
    # look into the audit table instead of the main table
    lappend date_clause_list "delete_p = :delete_p"
    ns_set put $bind_vars delete_p "t"

    set id_list [db_list audit_table_column_select "
        select distinct $id_column
          from $audit_table_name
         where [join $date_clause_list "\nand "]
    " -bind $bind_vars]
    ns_set free $bind_vars

    # Display the grouped modifications to each id in id_list
    foreach id $id_list {

        # Set the HTML link tags to a page which displays the full
        # audit history.
        if { ![empty_string_p $audit_url] } {
            set exports [export_url_vars id id_column main_table_name \
                    audit_table_name]
            set id_href "<a href=\"$audit_url?$exports\">"
            set id_href_close "</a>"
        } else {
            set id_href ""
            set id_href_close ""
        }

        ns_log debug ec_audit_trail_for_table dIs

        set cell [ec_audit_trail $id $audit_table_name \
                $main_table_name $id_column "" \
                $start_date $end_date $restore_url]
        append return_html "
        <h4>Deleted $id_column dIs $id_href$id$id_href_close</h4>
        <blockquote>
        <table border=1><tr><td>
        $cell
        </td></tr></table>
        </blockquote>
        "
    }

    return "
    <table bgcolor=bisque border=5 cellspacing=10 cellpadding=10>
      <tr>
        <td>
          $return_html
        </td>
      </tr>
    </table>
    "
}


ad_proc ec_audit_generate_column_name { table column { max_length 29 } } {
    Returns a max-length character (max) length identifier for the
    table and column name, joined at the hip by an underscore. This is
    used to ensure that bind variable names aren't too long.
} {
    set the_name "${table}_$column"
    if { [string length $the_name] <= $max_length } {
        return $the_name
    }
    set table_length [string length $table]
    set column_length [string length $column]
    set new_table_length [expr $max_length - $column_length - 1]
    if { $new_table_length > 0 } {
        set table [string range $table 0 $new_table_length]
        return "${table}_$column"
    } else {
        return [string range $column 0 $max_length]
    }
}

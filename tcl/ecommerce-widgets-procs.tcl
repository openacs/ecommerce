# /tcl/ecommerce-widgets.tcl

ad_library {
    Definitions for the ecommerce module
    @author Eve Andersson (eveander@arsdigita.com)
    @creation-date April, 1999
    @cvs-id ecommerce-widgets.tcl,v 3.3.2.7 2000/08/17 17:37:18 seb Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
}

ad_proc ec_search_widget { {category_id ""} {search_text ""} } { creates an ecommerce search widget, using the specified category id and search text if necessary } {
    return "<form method=post action=[ec_insecurelink product-search]>
<b>Search:</b> [ec_only_category_widget "f" $category_id] 
<input type=text size=25 name=search_text value=\"$search_text\">
<input type=submit value=\"Go\"></form>
"
}

ad_proc ec_only_category_widget { {multiple_p "f"} {default ""} } { category widget } {
    if { $multiple_p == "f" } {
	set select_tag "<select name=category_id>\n"
    } else {
	set select_tag "<select multiple name=category_id size=3>\n"
    }
   set to_return ""
    set category_counter 0
   
    db_foreach get_ec_categories "select category_id, category_name from ec_categories order by category_name" {

	if { $category_counter == 0} {
	    append to_return $select_tag
	}
	incr category_counter

	if { [lsearch -exact $default $category_id] != -1 || [lsearch -exact $default $category_name] != -1 } {
	    append to_return "<option value=$category_id selected>$category_name"	    
	} else {
	    append to_return "<option value=$category_id>$category_name"
	}
    }
    if { $category_counter != 0 } {
	append to_return "</select>\n"
    }
    return $to_return
}

# I think this will soon be no longer used.
# the select name will be subcategory_of_$category_id (because there will be
# cases when a product has multiple categories and there will therefore be
# more than one subcategory select list in one form)
ad_proc ec_subcategory_widget { category_id {multiple_p "f"} {default ""} } { subcategory widget } {
    if { $multiple_p == "f" } {
	set to_return "<select name=subcategory_of_$category_id>\n"
    } else {
	set to_return "<select multiple name=subcategory_of_$category_id size=3>\n"
    }
   set subcategory_counter 0
    db_foreach get_subcats_by_name "select subcategory_id, subcategory_name from ec_subcategories where category_id=:category_id order by subcategory_name" {
 
 
	incr subcategory_counter
	
	if { [string compare $default $subcategory_id] == 0 || [string compare $default $subcategory_name] == 0 } {
	    append to_return "<option value=$subcategory_id selected>$subcategory_name"
	} else {
	    append to_return "<option value=$subcategory_id>$subcategory_name"
	}
    }
    if { $subcategory_counter == 0 } {
	append to_return "<option value=\"\">There are no subcategories to choose from."
    }
    append to_return "</select>\n"
return $to_return
}

# gives a drop-down list and, if category_id_list is specified, it will display
# the templates associated with those categories (if any) first
ad_proc ec_template_widget { {category_id_list ""} {default ""} } { gives a drop-down list and, if category_id_list is specified, it will display the templates associated with those categories (if any) first } {
    set to_return "<select name=template_id>
    <option value=\"\">NONE\n"

    set top_template_list [list]
    if { ![empty_string_p $category_id_list] } {
	
	set sql "select m.template_id, t.template_name
from ec_category_template_map m, ec_templates t
where m.template_id=t.template_id
and m.category_id in ([join $category_id_list ", "])"

        set option_selected_p 0
        db_foreach get_templates_from_db $sql {
	    
	    if { $option_selected_p == 0 && ([empty_string_p $default] || $template_id == $default)} {
		incr option_selected_p
		append to_return "<option value=\"$template_id\" selected>$template_name\n"
	    } else {
		append to_return "<option value=\"$template_id\">$template_name\n"
	    }
	    lappend top_template_list $template_id
        }
    }

    # now get the templates that haven't already been selected
    set query_string "select template_id, template_name
from ec_templates t"

    if { [llength $top_template_list] > 0 } {
	append query_string " where t.template_id not in ([join $top_template_list ", "])"
    }

    set sql $query_string

    db_foreach get_template_info $sql {
	
	if { $template_id == $default } {
	    append to_return "<option value=\"$template_id\" selected>$template_name\n"
	} else {
	    append to_return "<option value=\"$template_id\">$template_name\n"
	}
    }

    append to_return "</select>\n"
  return $to_return
}

ad_proc ec_column_type_widget { {default ""} } { column type widget } {

    # boolean will be the default unless specified otherwise
    # if it's boolean, the check constraint will be added at the end so that it can be named
    set to_return "<select name=column_type>
    <option value=\"char(1)\">Boolean (Yes or No)
    "
    if { $default == "integer" } {
	append to_return "<option value=\"integer\" selected>Integer\n"
    } else {
	append to_return "<option value=\"integer\">Integer\n"
    }
    if { $default == "number" } {
	append to_return "<option value=\"number\" selected>Real Number\n"
    } else {
	append to_return "<option value=\"number\">Real Number\n"
    }
    if { $default == "date" } {
	append to_return "<option value=\"date\" selected>Date\n"
    } else {
	append to_return "<option value=\"date\">Date\n"
    }
    if { $default == "varchar(200)" } {
	append to_return "<option value=\"varchar(200)\" selected>Text - Up to 200 Characters\n"
    } else {
	append to_return "<option value=\"varchar(200)\">Text - Up to 200 Characters\n"
    }
    if { $default == "varchar(4000)" } {
	append to_return "<option value=\"varchar(4000)\" selected>Text - Up to 4000 Characters\n"
    } else {
	append to_return "<option value=\"varchar(4000)\">Text - Up to 4000 Characters\n"
    }
    append to_return "</select>\n"
    
    return $to_return
}

ad_proc ec_multiple_state_widget { {default_list ""} {select_name "usps_abbrev"}} "Returns a state multiple selection box of size 5" {

    set widget_value "<select multiple name=\"$select_name\" size=5>\n"
    set sql "select * from states order by state_name"
    db_foreach get_all_states $sql {
        
        if { [lsearch $default_list $usps_abbrev] != -1 } {
            append widget_value "<option value=\"$usps_abbrev\" SELECTED>$state_name</option>\n" 
        } else {            
            append widget_value "<option value=\"$usps_abbrev\">$state_name</option>\n"
        }
    }
    append widget_value "</select>\n"
    return $widget_value
}

ad_proc ec_reach_widget { {default ""} } { reach widget } {
    set to_return "<select name=reach>\n"
    foreach reach [list local national international regional web] {
	if { $reach == $default } {
	    append to_return "<option value=$reach selected>$reach\n"
	} else {
	    append to_return "<option value=$reach>$reach\n"
	}
    }
    append to_return "</select>\n"
    return $to_return
}

ad_proc ec_stock_status_widget { {default ""} } { returns stock status } {
    set to_return "<select name=stock_status>\n<option value=\"\">select one\n"
    foreach stock_status [list o q m s i] {
        set opt [util_memoize [list ad_parameter -package_id [ec_id] "StockMessage[string toupper $stock_status]" ecommerce] [ec_cache_refresh]]
	if { $default == $stock_status } {
	    append to_return "<option value=$stock_status selected>$opt\n"
	} else {
	    append to_return "<option value=$stock_status>$opt\n"
	}
    }
    append to_return "</select>\n"
    return $to_return
}

# it's ok to name all instances of this select list the same since 
# I'll be using ns_conn form anyway and I can get all of them
ad_proc ec_subcategory_with_subsubcategories_widget { category_id {multiple_p "f"} {default ""} } { returns subcategories with subcategories } {
    if { $multiple_p == "f" } {
	set to_return "<select name=subcategory_and_subsubcategory>\n"
    } else {
	set to_return "<select multiple name=subcategory_and_subsubcategory size=3>\n"
    }

    set subcategory_list [db_list get_subcategory_ids "select subcategory_id from ec_subcategories where category_id=:category_id"]
    set subcategory_counter 0
    foreach subcategory_id $subcategory_list {
	incr subcategory_counter
	set subcategory_name [db_string get_subcategory_names "select subcategory_name from ec_subcategories where subcategory_id=:subcategory_id"]
	append to_return "<option value=\"[list $subcategory_id ""]\">$subcategory_name\n"

	set sql "select subsubcategory_id, subsubcategory_name from ec_subsubcategories where subcategory_id=:subcategory_id"]
	db_foreach get_subcategory_info $sql {
	    
	    append to_return "<option value=\"[list $subcategory_id $subsubcategory_id]\">$subcategory_name -- $subsubcategory_name\n"
	}

    }
    if { $subcategory_counter == 0 } {
	append to_return "<option value=\"\">There are no subcategories to choose from."
    }
    append to_return "</select>\n"

    return $to_return
}

# displays all categories, subcategories, and subsubcategories
# default is a list of all the items you want selected
ad_proc ec_category_widget { {multiple_p "f"} {default ""} {allow_null_categorization "f"}} { displays all categories, subcategories, and subsubcategories, default is a list of all the items you want selected } {
    if { $multiple_p == "f" } {
	set to_return "<select name=categorization>\n"
    } else {
	set to_return "<select multiple name=categorization size=7>\n"
    }
    if { $allow_null_categorization == "t" } {
	append to_return "<option value=\"\">Top Level\n"
    }
    set sql "
    select c.category_id, c.category_name,
           s.subcategory_id, s.subcategory_name,
           ss.subsubcategory_id, ss.subsubcategory_name
      from ec_categories c, ec_subcategories s, ec_subsubcategories ss
     where c.category_id = s.category_id (+)
       and s.subcategory_id = ss.subcategory_id (+)
  order by c.sort_key, s.sort_key, ss.sort_key"

    set category_counter 0
    set old_category_id ""
    set old_subcategory_id ""
    db_foreach get_category_info_joined_w_children $sql {
	incr category_counter
	
	
	if { $category_id != $old_category_id } {

	    if { [lsearch -exact $default $category_id] != -1 || [lsearch -exact $default $category_name] != -1 } {
		append to_return "<option value=$category_id selected>$category_name\n"
	    } else {
		append to_return "<option value=$category_id>$category_name\n"
	    }
	    set old_category_id $category_id
	} ; # end of new category line
	    
	if { $subcategory_id != $old_subcategory_id && ![empty_string_p $subcategory_id]} {
	    if { [lsearch -exact $default "$category_id $subcategory_id"] != -1 } {
		append to_return "<option value=\"$category_id $subcategory_id\" selected>&nbsp;&nbsp;&nbsp;&nbsp;$subcategory_name\n"
	    } else {
		append to_return "<option value=\"$category_id $subcategory_id\">&nbsp;&nbsp;&nbsp;&nbsp;$subcategory_name\n"
	    }
	    set old_subcategory_id $subcategory_id
	} ; # end of new subcategory line

	if { ![empty_string_p $subsubcategory_id] } {
	    if { [lsearch -exact $default "$category_id $subcategory_id $subsubcategory_id"] != -1 } {
		append to_return "<option value=\"$category_id $subcategory_id $subsubcategory_id\" selected>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$subsubcategory_name\n"
	    } else {
		append to_return "<option value=\"$category_id $subcategory_id $subsubcategory_id\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$subsubcategory_name\n"
	    }
	}

    }
    if { $category_counter == 0 } {
	append to_return "<option value=\"\">There are no categories to choose from."
    }
    append to_return "</select>\n"
  return $to_return
}

# Shows mailing lists (i.e., categories/subcategories/subsubcategories, at least for now)
# that have members, either in a drop-down list (if drop_down_p is "t") or as a <ul> with
# links to one.tcl (if drop_down_p is "f").  These are both used in the admin pages; the
# drop-down list is used when spamming members, and the <ul> is used when administering
# mailing lists.
# For subsubcategories (similarly for subcategories), it displays 
# category: subcategory: subsubcategory instead of just subsubcategory
# because there might not be anyone in the mailing list for that category
# so that category won't show up above it
# default is a list of all the items you want selected
ad_proc ec_mailing_list_widget { {drop_down_p "t"} {multiple_p "f"} {default ""} {allow_null_categorization "f"}} { shows mailing lists for categories, subcategories, subsub } {
    if { $drop_down_p == "t" } {
	if { $multiple_p == "f" } {
	    set to_return "<select name=mailing_list>\n"
	} else {
	    set to_return "<select multiple name=mailing_list size=7>\n"
	}
	if { $allow_null_categorization == "t" } {
	    append to_return "<option value=\"\">Top Level\n"
	}
    } else {
	set to_return "<ul>"
    }

    set loop_detector [string length $to_return]

    set sql "
    select c.category_id, c.category_name, s.subcategory_id, s.subcategory_name, ss.subsubcategory_id, ss.subsubcategory_name
      from ec_categories c, ec_subcategories s, ec_subsubcategories ss, ec_cat_mailing_lists m
     where m.category_id=c.category_id(+)
       and m.subcategory_id=s.subcategory_id(+)
       and m.subsubcategory_id=ss.subsubcategory_id(+)
 order by decode(c.category_id, null, 0, c.sort_key), decode(s.subcategory_id, null, 0, s.sort_key), decode(ss.subcategory_id, null, 0, ss.sort_key)
    "

    set old_category_id ""
    set old_subcategory_id ""
    set old_subsubcategory_id ""
    db_foreach get_category_children $sql {
	
	if { [string compare $old_category_id $category_id] != 0 || [string compare $old_subcategory_id $subcategory_id] != 0 || [string compare $old_subsubcategory_id $subsubcategory_id] != 0 } {
	    if { $drop_down_p == "t" } {
		append to_return "<option value=\""

		if { ![empty_string_p $category_id] } {
		    append to_return "$category_id"
		}
		
		if { ![empty_string_p $subcategory_id] } {
		    append to_return " $subcategory_id"
		}
		if { ![empty_string_p $subsubcategory_id] } {
		    append to_return " $subsubcategory_id"
		}
		
		append to_return "\">"
	    } else {
		append to_return "<li><a href=\"one"
		
		if { ![empty_string_p $category_id] } {
		    append to_return "?category_id=$category_id"
		}

		if { ![empty_string_p $subcategory_id] } {
		    append to_return "&subcategory_id=$subcategory_id"
		}

		if { ![empty_string_p $subsubcategory_id] } {
		    append to_return "&subsubcategory_id=$subsubcategory_id"
		}
		append to_return "\">"
	    }
	    
	    append to_return "$category_name"

	    if { ![empty_string_p $subcategory_id] } {
		append to_return ": $subcategory_name"
	    }
	    if { ![empty_string_p $subsubcategory_id] } {
		append to_return ": $subsubcategory_name"
	    }

	    if { $drop_down_p == "f" } {
		append to_return "</a>"
	    }
	}
        set old_category_id $category_id
        set old_subcategory_id $subcategory_id
        set old_subsubcategory_id $subsubcategory_id
    }
    if {[string length $to_return] == $loop_detector} {
        set to_return "
        <b>none</b>
        "
    } else {

        if { $drop_down_p == "t" } {
            append to_return "</select>"
        } else {
            append to_return "</ul>"
        }
    }
    return $to_return
}

ad_proc ec_rating_widget { } { ratings widget } {
    return "<p><ul><input type=radio name=rating value=5> [ec_display_rating 5] &nbsp; 5 Stars
<br><input type=radio name=rating value=4 default> [ec_display_rating 4] &nbsp; 4 Stars
<br><input type=radio name=rating value=3> [ec_display_rating 3] &nbsp; 3 Stars
<br><input type=radio name=rating value=2> [ec_display_rating 2] &nbsp; 2 Stars
<br><input type=radio name=rating value=1> [ec_display_rating 1] &nbsp; 1 Star
</ul>
"
}

# given category_list, subcategory_list, and subsubcategory_list, this determines
# which options of the categorization widget should be selected by default (when
# editing a product)
ad_proc ec_determine_categorization_widget_defaults { category_list subcategory_list subsubcategory_list } { given category_list, subcategory_list, and subsubcategory_list, this determines which options of the categorization widget should be selected by default (when editing a product) } {

  

    if { [empty_string_p $category_list] } {
	return [list]
    }

    set to_return [list]
    foreach category_id $category_list {

	if { ![empty_string_p $subcategory_list] } {
	    set relevant_subcategory_list [db_list get_sub_list "select subcategory_id from ec_subcategories where category_id=:category_id and subcategory_id in ([join $subcategory_list ","]) order by subcategory_name"]
	} else {
	    set relevant_subcategory_list [list]
	}

	if { [llength $relevant_subcategory_list] == 0 } {
	    lappend to_return $category_id
	} else {
	    foreach subcategory_id $relevant_subcategory_list {

		if { ![empty_string_p $subsubcategory_list] } {
		    set relevant_subsubcategory_list [db_list get_subsub_list "select subsubcategory_id from ec_subsubcategories where subcategory_id=:subcategory_id and subsubcategory_id in ([join $subsubcategory_list ","]) order by subsubcategory_name"]
		} else {
		    set relevant_subsubcategory_list [list]
		}
		

		if { [llength $relevant_subsubcategory_list] == 0 } {
		    lappend to_return "$category_id $subcategory_id"
		} else {
		    foreach subsubcategory_id $relevant_subsubcategory_list {
			lappend to_return "$category_id $subcategory_id $subsubcategory_id"
		    }
		}

	    } ; # end foreach subcategory_id

	} ; # end of case where relevant_subcategory_list is non-empty

    } ; # end foreach category_id
	    
  return $to_return
}

ad_proc ec_continue_shopping_options { } { returns continue shopping options } {
    return "<form method=post action=\"category-browse\">
Continue Shopping for [ec_only_category_widget] 
<input type=submit value=\"Go\">
</form>
"
}

ad_proc ec_country_widget { {default ""} {select_name "country_code"} {size_subtag "size=4"}} "Just like country_widget, except it's not United States centric." {

    set widget_value "<select name=\"$select_name\" $size_subtag>\n"
    if { $default == "" } {
        append widget_value "<option value=\"\" SELECTED>Choose a Country</option>\n"
    }
    set sql "select country_name, iso from country_codes order by country_name"
     db_foreach get_countries $sql {
        
        if { $default == $iso } {
            append widget_value "<option value=\"$iso\" SELECTED>$country_name</option>\n" 
        } else {            
            append widget_value "<option value=\"$iso\">$country_name</option>\n"
        }
    }
    append widget_value "</select>\n"
    return $widget_value
}

ad_proc ec_creditcard_expire_1_widget {{default ""}} "Gives the HTML for the Expiration Date Month select list." {
    set header "<select name=creditcard_expire_1>\n"
    set footer "</select>\n"
    set defaulted_flag 0
    foreach size [list "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12"] {
	if { $size == $default } {
	    append options "<option VALUE=$size SELECTED>$size\n"
	    set defaulted_flag 1
	} else {
	    append options "<option VALUE=$size>$size\n"
	}
    }
    if $defaulted_flag {
	return "$header$options$footer"
    } else {
	return "${header}<option value=\"\" SELECTED>select\n$options$footer"
    }
}

ad_proc ec_creditcard_expire_2_widget {{default ""}} "Gives the HTML for the Expiration Date Year select list." {
    set header "<select name=creditcard_expire_2>\n"
    set footer "</select>\n"
    set defaulted_flag 0
    foreach option_spec [list [list "01" 2001] [list "02" 2002] [list "03" 2003] [list "04" 2004] [list "05" 2005] [list "06" 2006] [list "07" 2007] [list "08" 2008] ] {
	set size_for_db [lindex $option_spec 0]
	set size [lindex $option_spec 1]
	if { [string compare $size $default] == 0 || [string compare $size_for_db $default] == 0 } {
	    append options "<option value=\"$size_for_db\" SELECTED>$size\n"
	    set defaulted_flag 1
	} else {
	    append options "<option value=\"$size_for_db\">$size\n"
	}
    }
    if $defaulted_flag {
	return "$header$options$footer"
    } else {
	return "${header}<option value=\"\" SELECTED>select\n$options$footer"
    }
}

ad_proc ec_creditcard_widget { {default ""} } { credit card selector } {
    set to_return "<SELECT NAME=creditcard_type>
<option value=\"\">Please select one
<OPTION VALUE=\"a\""
if { $default == "a" } {
    append to_return " selected"
}
append to_return ">American Express
<OPTION VALUE=\"m\""
if { $default == "m" } {
    append to_return " selected"
}
append to_return ">MasterCard
<OPTION VALUE=\"v\""
if { $default == "v" } {
    append doc_body " selected"
}
append to_return ">Visa
</SELECT>
"
return $to_return
}

ad_proc ec_date_widget {column {date ""}} {Generates a date widget.} {
  switch $date {
    now {
      set date [db_string date_widget_select "select to_char(sysdate, 'YYYY-MM-DD') from dual"]
    }
  }

  if {[empty_string_p $date]} {
    set year ""
    set month ""
    set day ""
  } else {
    set parts [split $date "-"]
    set year [lindex $parts 0]
    set month [lindex $parts 1]
    set day [lindex $parts 2]
  }

  set result "<select name=\"$column.month\">\n"

  set month_names [list \
      "January" \
      "Febuary" \
      "March" \
      "April" \
      "May" \
      "June" \
      "July" \
      "August" \
      "September" \
      "October" \
      "Novemeber" \
      "December"]

  for {set i 0} {$i < 12} {incr i} {
    if {$i + 1 == $month} {
      set maybe_select " selected"
    } else {
      set maybe_select ""
    }
    append result "<option value=[expr $i + 1]$maybe_select>[lindex $month_names $i]</option>\n"
  }

  append result "</select>\n"
  append result "<input type=text name=\"$column.day\" size=3 maxlength=2 value=\"$day\">&nbsp;"
  append result "<input type=text name=\"$column.year\" size=5 maxlength=4 value=\"$year\">"

  return $result
}

ad_proc ec_date_text {column} {Returns a textual representation of the date.} {
  upvar $column date
  if {[empty_string_p $date(year)] && [empty_string_p $date(day)]} {
    return ""
  } else {
    return "$date(year)-$date(month)-$date(day)"
  }
}

ad_proc ec_date_widget_validate {column} {Validates a date widget.} {
  upvar $column date

  set errmsgs [list]

  if {[empty_string_p $date(year)] && [empty_string_p $date(day)]} {
    return
  }

  if {![regexp {[0-9]+} $date(year)]} {
    lappend errmsgs "Year must be a positive integer."
  }
  if {![regexp {[0-9]+} $date(day)]} {
    lappend errmsgs "Day must be a positive integer."
  }

  if {$date(day) > 31} {
    lappend errmsgs "Day is out of range."
  }

  if {[llength $errmsgs] > 0} {
    error [join $errmsgs "<br>\n"]
  }
}

ad_proc ec_time_widget {column {time ""}} {Generates a time widget.} {
  switch $time {
    now {
      set time [db_string time_widget_select "select to_char(sysdate, 'HH24:MI:SS') from dual"]
    }
  }

  if {[empty_string_p $time]} {
    set hour ""
    set minute ""
    set second ""
    set ampm "PM"
  } else {
    set parts [split $time ":"]
    set hour [lindex $parts 0]
    set minute [lindex $parts 1]
    set second [lindex $parts 2]

    if {$hour > 12} {
      incr hour -12
      set ampm "PM"
    } else {
      if {$hour == 0} {
	set hour 12
	set ampm "AM"
      } else {
	set ampm "PM"
      }
    }
  }

  return "<input type=text name=\"$column.hour\" size=3 maxlength=2 value=\"$hour\"> : <input type=text name=\"$column.minute\" size=3 maxlength=2 value=\"$minute\"> : <input type=text name=\"$column.second\" size=3 maxlength=2 value=\"$second\"> <select name=\"$column.ampm\"><option [util_decode $ampm "AM" selected ""]>AM</option><option [util_decode $ampm "PM" selected ""]>PM</option></select>"
}

ad_proc ec_time_text {column} {Returns a textual representation of the time.} {
  upvar $column time
  set hour $time(hour)
  if {[empty_string_p $hour]} {
    return ""
  }
  switch $time(ampm) {
    AM {
      if {$hour == 12} {
	set hour 0
      }
    }
    PM {
      if {$hour != 12} {
	incr hour 12
      }
    }
  }
  return "$hour:$time(minute):$time(second)"
}

ad_proc ec_time_widget_validate {column} {Validates time widget input.} {
  upvar $column time
  set errmsgs [list]

  if {[empty_string_p $time(second)]} {
    set time(second) "00"
  }

  if {[empty_string_p $time(minute)]} {
    set time(minute) "00"
  }

  if {![regexp {[0-9]+} $time(minute)]} {
    lappend errmsgs "Minute must be a positive integer."
  }
  if {![regexp {[0-9]+} $time(second)]} {
    lappend errmsgs "Second must be a positive integer."
  }
  if {$time(minute) > 59} {
    lappend errmsgs "Minute must be less than 60."
  }
  if {$time(second) > 59} {
    lappend errmsgs "Second must be less than 60."
  }

  if {[llength $errmsgs] > 0} {
    error [join $errmsgs "<br>\n"]
  }

  if {[empty_string_p $time(hour)]} {
    return
  }

  if {![regexp {[0-9]+} $time(hour)]} {
    lappend errmsgs "Hour must be a positive integer."
  }
  if {$time(hour) > 12 || $time(hour) < 1} {
    lappend errmsgs "Hour must be between 1 and 12."
  }

  if {[llength $errmsgs] > 0} {
    error [join $errmsgs "<br>\n"]
  }
}

ad_proc ec_datetime_text {column} {Generates a textual representation of the date and time.} {
  upvar $column dt
  set date_text [ec_date_text dt]
  set time_text [ec_time_text dt]
  if {[empty_string_p $time_text]} {
    return $date_text
  } elseif {[empty_string_p $date_text]} {
    return $time_text
  } else {
    return "$date_text $time_text"
  }
}

ad_proc ec_datetime_sql {column} {Generates a sql datetime expression from a date widget or a date widget and a time widget.} {
  upvar $column dt
    # wtem@olywa.net, 2001-03-28
    # needs to be able to handle a null value
    if {![empty_string_p $dt(year)] || ![empty_string_p $dt(day)] || ![empty_string_p $dt(month)]} {
	if {[info exists dt(ampm)]} {
	    return "to_date('[DoubleApos "$dt(year)-$dt(month)-$dt(day) $dt(hour):$dt(minute):$dt(second) $dt(ampm)"]', 'YYYY-MM-DD HH12:MI:SS PM')"
	} else {
	    return "to_date('[DoubleApos "$dt(year)-$dt(month)-$dt(day)"]', 'YYYY-MM-DD')"
	}
    } else {
        return "null"
    }
}

ad_proc ec_timeentrywidget {column {timestamp 0}} "Gives a HTML form input for a time. If timestamp is not supplied, time defaults to current time. For a blank time, set timestamp to the empty string. " {
    
    if { $timestamp == 0 } {
	# no default, so use current time
	set timestamp [ns_localsqltimestamp]
    }

    if { ![regexp -nocase {([0-9]+):([0-9]+):([0-9]+ *(am|pm)?)} $timestamp match hours mins secsampm]} {
	#  Timestamp is in invalid format or simply empty.
	#  Void each of its fields.
	set time ""
	set ampm ""
    } else {
	#  Get seconds out of secsampm
	regexp {[0-9]+} $secsampm secs
	#  Get rid of leading 0's
	regexp {^0([^0].*)} $hours match hours
	regexp {^0([^0].*)} $mins match mins
	regexp {^0([^0].*)} $secs match secs
	if { [regexp -nocase {am} $secsampm] } {
	    set ampm AM
	} elseif { [regexp -nocase {pm} $secsampm] } {
	    set ampm PM
	} else {
	    # assume that we're dealing with military time
	    set ampm AM
	    if {$hours == 0} {
		set hours 12
	    } elseif {$hours == 12} {
		set ampm PM
	    } elseif {$hours > 12} {
		set ampm PM
		incr hours -12
	    }
	}
	set time "$hours:$mins:$secs"
    }

    set output "<INPUT NAME=\"$column.time\" TYPE=text SIZE=9 VALUE=\"$time\">&nbsp;
<SELECT NAME=\"$column.ampm\">
[ad_generic_optionlist [list "" AM PM] [list "" AM PM] $ampm]
</SELECT>"

    return $output

}

ad_proc ec_timeentrywidget_time_check { timestamp } {
    checks to make sure that the time part of the timestamp is in the correct format:  HH12:MI:SS.  For instance 02:20:00.  PostgreSQL does not like it when you leave out a digit (id 2:20:00) and it will complain. 
} {
    if { ![regexp -nocase {([0-9]+):([0-9]+):([0-9]+)} $timestamp match hours mins secs]} {
	ad_return_complaint "1" "<li>The time part of the timestamp is not in the correct format.  It must be HH12:MI:SS" 
	return -code return
    } else {
        #  check to make sure each field has two digits
        if ![regexp {[0-9][0-9]} $hours] {
	    set hours 0$hours
	}
        if ![regexp {[0-9][0-9]} $mins] {
	    set mins 0$mins
	}
        if ![regexp {[0-9][0-9]} $secs] {
	    set secs 0$secs
	}
        set time "$hours:$mins:$secs"
    }
    return $time
}

ad_proc ec_user_class_widget { {default ""} } { user class select } {
  
    set to_return "<select name=user_class_id>
    <option value=\"\">All Users
    "

    set sql "select user_class_id, user_class_name from ec_user_classes order by user_class_id"
    db_foreach get_user_class_info $sql {
	
	append to_return "<option value=\"$user_class_id\""
	if { $user_class_id == $default } {
	    append to_return " selected"
	}
	append to_return ">$user_class_name\n"
    }
    append to_return "</select>\n"

  return $to_return
}

ad_proc ec_user_class_select_widget { {default ""} {multiple t}} "Returns a HTML multiple select list for user_class_id with an option for each user class. Each id in the list default is selected." {
    set to_return "<select [ec_decode $multiple "t" "multiple" ""] name=user_class_id>
    <option value=\"\">none selected
    "

    set sql "select user_class_id, user_class_name from ec_user_classes order by user_class_id"
    db_foreach get_user_class_info $sql {
	
	append to_return "<option value=\"$user_class_id\""
	if { [lsearch -exact $default $user_class_id] != -1 } {
	    append to_return " selected"
	}
	append to_return ">$user_class_name\n"
    }
    append to_return "</select>\n"
    return $to_return
}

ad_proc ec_issue_type_widget { {default ""} } { issue type widget } {
    set to_return "<table><tr><td valign=top>Pick as many as you like:</td><td>
    "
    set issue_type_list [db_list get_picklist_items "select picklist_item from ec_picklist_items where picklist_name='issue_type' order by sort_key"]

    foreach issue_type $issue_type_list {
	append to_return "<input type=checkbox name=issue_type value=\"$issue_type\""
	if { [lsearch -exact $default $issue_type] != -1 } {
	    append to_return " checked"
	}
	append to_return ">$issue_type<br>\n"
    }
    # we only allow there to be one issue_type that isn't in the issue_type_list;
    # if we decide otherwise, we can change the text input box to a textarea,
    # use ec_elements_of_list_a_that_arent_in_list_b instead of
    # ec_first_element_of_list_a_that_isnt_in_list_b, and process the input 
    # differently on all pages that take in form data which includes issue_type;
    # but I think this will take care of just about every case
    append to_return "other:
    <input type=text name=issue_type size=10 value=\"[ad_quotehtml [ec_first_element_of_list_a_that_isnt_in_list_b $default $issue_type_list] ]\">
    </td></tr></table>
    "
    return $to_return
}

ad_proc ec_info_used_widget { {default ""} } { info used widget } {
    set to_return "<table><tr><td valign=top>Pick as many as you like:</td><td>
    "
    set info_used_list [db_list get_info_used_list "select picklist_item from ec_picklist_items where picklist_name='info_used' order by sort_key"]

    foreach info_used $info_used_list {
	append to_return "<input type=checkbox name=info_used value=\"$info_used\""
	if { [lsearch -exact $default $info_used] != -1 } {
	    append to_return " checked"
	}
	append to_return ">$info_used<br>\n"
    }
    append to_return "other:
    <input type=text name=info_used size=10 value=\"[ad_quotehtml [ec_first_element_of_list_a_that_isnt_in_list_b $default $info_used_list] ]\">
    </td></tr></table>
    "
    return $to_return
}

ad_proc ec_interaction_type_widget { {default ""} } { interaction type widget } {
    set to_return "<select name=interaction_type>
    "
    set interaction_type_list [db_list get_interaction_type_list "
    select picklist_item
      from ec_picklist_items
     where picklist_name='interaction_type'
  order by sort_key
    "]

    foreach interaction_type $interaction_type_list {
	append to_return "<option value=\"[ad_quotehtml $interaction_type]\">$interaction_type"
    }
    append to_return "<option value=\"other\">other
    </select>
    If Other, specify:
    <input type=text name=interaction_type_other size=15>
    "
    return $to_return
}

ad_proc ec_report_date_range_widget { start_date end_date } { report date range widget } {
    return "from [ad_dateentrywidget start_date $start_date]
<INPUT NAME=start%5fdate.time TYPE=hidden value=\"12:00:00\">
<INPUT NAME=start%5fdate.ampm TYPE=hidden value=\"AM\">

through  [ad_dateentrywidget end_date $end_date]
<INPUT NAME=end%5fdate.time TYPE=hidden value=\"11:59:59\">
<INPUT NAME=end%5fdate.ampm TYPE=hidden value=\"PM\">
"
}

ad_proc ec_generic_html_form_select_widget {name_of_select option_spec_list {default ""}} "This is a generalization of all the other widgets we have that create HTML select lists.  You can use this directly in your HTML code, but I have tended to use it inside of other procs to just more quickly create the widget." {
    set header "<select name=$name_of_select>\n"
    set footer "</select>\n"
    set defaulted_flag 0
    foreach option_spec $option_spec_list {
	set size_for_db [lindex $option_spec 0]
	set size [lindex $option_spec 1]
	if { [string compare $size $default] == 0 || [string compare $size_for_db $default] == 0 } {
	    append options "<option value=\"$size_for_db\" SELECTED>$size\n"
	    set defaulted_flag 1
	} else {
	    append options "<option value=\"$size_for_db\">$size\n"
	}
    }
    if $defaulted_flag {
	return "$header$options$footer"
    } else {
	return "${header}<option value=\"\" SELECTED>select\n$options$footer"
    }
}

ad_proc ec_gift_certificate_expires_widget { {default "none"} } "Gives the HTML code for the select list from which customer service can change when a consumer's gift_certificate expires." {
    set option_spec_list [list [list "sysdate + 1" "in 1 day"] [list "sysdate + 2" "in 2 days"] [list "sysdate + 3" "in 3 days"] [list "sysdate + 4" "in 4 days"] [list "sysdate + 5" "in 5 days"] [list "sysdate + 6" "in 6 days"] [list "sysdate + 7" "in 1 week"] [list "sysdate + 14" "in 2 weeks"] [list "sysdate + 21" "in 3 weeks"] [list "add_months(sysdate,1)" "in 1 month"] [list "add_months(sysdate,2)" "in 2 months"] [list "add_months(sysdate,3)" "in 3 months"] [list "add_months(sysdate,4)" "in 4 months"] [list "add_months(sysdate,5)" "in 5 months"] [list "add_months(sysdate,6)" "in 6 months"] [list "add_months(sysdate,7)" "in 7 months"] [list "add_months(sysdate,8)" "in 8 months"] [list "add_months(sysdate,9)" "in 9 months"] [list "add_months(sysdate,10)" "in 10 months"] [list "add_months(sysdate,11)" "in 11 months"] [list "add_months(sysdate,12)" "in 1 year"] [list "add_months(sysdate,24)" "in 2 years"] ]

    set name_of_select "expires"
    
    return "[ec_generic_html_form_select_widget $name_of_select $option_spec_list $default]"

}

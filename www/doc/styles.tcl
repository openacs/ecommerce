ad_page_contract {
    page that shows all the defined styles
    in the system

    @param sort_by

    @author ?
    @creation-date ?
    @cvs-id styles.tcl,v 3.2.2.3 2000/09/22 01:37:23 kevin Exp
    @author ported by Jerry Asher (jerry@theashergroup.com)
} {
    sort_by:optional
}


ns_share ad_styletag
ns_share ad_styletag_source_file

# we assume that we get a list of lists, each one containing
# {proc_name filename} (i.e., a Tcl list in its own right)

proc procs_tcl_sort_by_first_element {l1 l2} {
    set first_comparison [string compare [lindex $l1 0] [lindex $l2 0]]
    if { $first_comparison != 0 } {
	return $first_comparison
    } else {
	return [string compare [lindex $l1 1] [lindex $l2 1]]
    }
}

proc procs_tcl_sort_by_second_element {l1 l2} {
    set first_comparison [string compare [lindex $l1 1] [lindex $l2 1]]
    if { $first_comparison != 0 } {
	return $first_comparison
    } else {
	return [string compare [lindex $l1 0] [lindex $l2 0]]
    }
}


set page_content "
[ad_header "Defined Styles"]

<h2>Defined Styles</h2>

in this installation of the ArsDigita Community System

<hr>

This page lists those styles that the programmers have defined
using <code>ec_register_styletag</code> (defined in /tcl/ad-style.tcl).

<p>

"

set list_of_lists [list]

foreach style_name [array names ad_styletag] {
    lappend list_of_lists [list $style_name $ad_styletag_source_file($style_name)]
}

if { [info exists sort_by] && $sort_by == "name" } {
    set sorted_list [lsort -command procs_tcl_sort_by_first_element $list_of_lists]
    set headline "Styles by Name"
    set options "or sort by <a href=\"styles?sort_by=filename\">source file name</a>"
} else {
    # by filename
    set sorted_list [lsort -command procs_tcl_sort_by_second_element $list_of_lists]
    set headline "Styles by source filename"
    set options "or sort by <a href=\"styles?sort_by=name\">name</a>"
}

append page_content "

<h3>$headline</h3>

$options

<ul>
"

set last_filename ""
foreach sublist $sorted_list {
    set style_name [lindex $sublist 0]
    set filename [lindex $sublist 1]
    if { [info exists sort_by] && $sort_by == "name"} {
	append page_content "<li><a href=\"style-one?style_name=[ns_urlencode $style_name]\">$style_name</a> (defined in $filename)"
    } else {
	# we're doing this by filename
	if { $filename != $last_filename } {
	    append page_content "<h4>$filename</h4>\n"
	    set last_filename $filename
	}
	append page_content "<li><a href=\"style-one?style_name=[ns_urlencode $style_name]\">$style_name</a>\n"
    }
}

append page_content "
</ul>

[ad_admin_footer]
"

db_release_unused_handles
doc_return 200 text/html $page_content


# spell.tcl,v 3.0 2000/02/06 03:54:45 ron Exp
# Jan 6, 2000  (OUMI) 
#    added html_p argument, set to 1 if $var_to_spellcheck contains html tags 
#    and you don't want to spell check the HTML tags.  Also fixed a bug in
#    the exporting of $processed_text.

# spell.tcl 

# Written by Jin Choi (jsc@arsdigita.com), with additions by Eve Andersson
# (eveander@arsdigita.com). Added to the ACS July 5, 1999.

# See http://photo.net/doc/tools.html for more information and usage
# example.

# Arguments: merge_p, var_to_spellcheck, target_url, error_0, error_1...
#            html_p
#
# To use, call with var_to_spellcheck, target_url, and whatever form
# variable you specified as var_to_spellcheck. You can also specify
# html_p (set to 't') if the variable to spellcheck contains HTML tags
# and you don't want the tags to get spell checked.
#
# merge_p and the error variables are internal arguments.

# This script runs in two modes.

# If merge_p is not set or is 0, we display the form variable specified by
# VAR_TO_SPELLCHECK with any misspellings
# as reported by ispell replaced by either a text field (if it ispell
# marked it as a "miss") or by a drop down box (if ispell marked it a
# "near miss"), and target ourself with the text to merge, the number
# of errors, and each error as error_0, error_1, ... error_n.

# If merge_p is true, we take the results of the above form, merge the
# corrections back into the text, and pass everything on to TARGET_URL.

# In either case, we re-export any form variable we don't use.

proc spell_sorted_list_with_unique_elements {the_list} {

    set sorted_list [lsort $the_list]
    set new_list [list]

    set old_element "XXinitial_conditionXX"
    foreach list_element $sorted_list {
	if { $list_element != $old_element } {
	    lappend new_list $list_element
	}
	set old_element $list_element
    }

    return $new_list
}


set form [ns_conn form]
set var_to_spellcheck [ns_set get $form var_to_spellcheck]
set text [ns_set get $form $var_to_spellcheck]
set html_p [ns_set get $form html_p]
set merge_p [ns_set get $form merge_p]
ns_set delkey $form $var_to_spellcheck
ns_set delkey $form merge_p

if { $merge_p == "" || $merge_p == 0 } {

    # if $html_p then substitute out all HTML tags
    set text_to_spell_check $text
    if {[string compare $html_p "t"] == 0} {
	regsub -all {<[^<]*>} $text_to_spell_check "" text_to_spell_check
    }

    set tmpfile [ns_mktemp "/tmp/webspellXXXXXX"]
    set f [open $tmpfile w]
    puts $f $text_to_spell_check
    close $f
    
    set lines [split $text "\n"]
    
    set dictionaryfile [ns_normalizepath "[ns_info pageroot]/../packages/ecommerce/www/admin/tools/ispell-words"]

    # The webspell wrapper is necessary because ispell requires
    # the HOME environment set, and setting env(HOME) doesn't appear
    # to work from AOLserver.
    set spelling_program [ns_normalizepath "[ns_info pageroot]/../packages/ecommerce/www/admin/tools/webspell"]

    set ispell_proc [open "|$spelling_program $tmpfile $dictionaryfile" r]

    # read will occasionally error out with "interrupted system call",
    # so retry a few times in the hopes that it will go away.
    set try 0
    set max_retry 10
    while {[catch {set ispell_text [read -nonewline $ispell_proc]} errmsg]
	   && $try < $max_retry} {
	incr try
	ns_log Notice "spell.tcl had a problem: $errmsg"
    }
    close $ispell_proc
    ns_unlink $tmpfile

    if { $try == $max_retry } {
	ns_return 200 text/html "[ad_header "Spell Checker Error"]
<h2>Spell Checker Error</h2>
<hr>
The spell checker was unable to process your document.  Please hit \"Reload\" to try again  If this message occurs again, please contact <a href=\"mailto:[ad_system_owner]\">[ad_system_owner]</a>.
[ad_footer]"
        return
    }
    
    set ispell_lines [split $ispell_text "\n"]
    # Remove the version line.
    if { [llength $ispell_lines] > 0 } {
	set ispell_lines [lreplace $ispell_lines 0 0]
    }
    
    set error_num 0
    set errors [list]
    
    set processed_text ""
    
    set line [lindex $lines 0]
    
    foreach ispell_line $ispell_lines {
	switch -glob -- $ispell_line {
	    "#*" {
		regexp "^\# (\[^ \]+) (\[0-9\]+)" $ispell_line dummy word pos
		regsub $word $line "\#$error_num\#" line
		lappend errors [list miss $error_num $word]
		incr error_num
	    }
	    "&*" {
		regexp {^& ([^ ]+) ([0-9]+) ([0-9]+): (.*)$} $ispell_line dummy word n_options pos options
		regsub $word $line "\#$error_num\#" line
		lappend errors [list nearmiss $error_num $word $options]
		incr error_num
	    }
	    "" {
		append processed_text "$line\n"
		if { [llength $lines] > 0 } {
		    set lines [lreplace $lines 0 0]
		    set line [lindex $lines 0]
		}
	    }
	}
    }
    
    
    if { $error_num == 0 } {
	# then there were no errors, so we just want to skip the user to the next screen
	set merge_p 1
	set error_free_p 1
    } else {
	
	set formtext $processed_text
	foreach err $errors {
	    set errtype [lindex $err 0]
	    set errnum [lindex $err 1]
	    set errword [lindex $err 2]
	    set wordlen [string length $errword]
	    
	    if { $errtype == "miss" } {
		regsub "\#$errnum\#" $formtext "<input type=text name=error_$errnum value=\"$errword\" size=$wordlen>" formtext
	    } elseif { $errtype == "nearmiss" } {
		set erroptions [lindex $err 3]
		regsub -all ", " $erroptions "," erroptions
		set options [split $erroptions ","]
		set select_text "<select name=error_$errnum>\n<option value=\"$errword\">$errword</option>\n"
		foreach option $options {
		    append select_text "<option value=\"$option\">$option</option>\n"
		}
		append select_text "</select>\n"
		regsub "\#$errnum\#" $formtext $select_text formtext
	    }
	    
	}
	
	# regsub -all {"} $processed_text {\&quot;} processed_text
	# a regsub isn't enough for exporting $processed_text in
	# a hidden variable.
	set processed_text [philg_quote_double_quotes $processed_text]

        ReturnHeaders
	ns_write "[ad_header "Spell Checker"]
	<h2>Spell Checker</h2>
	<hr>
	The spell checker has found one or more words in your document which could not be found in our dictionary.
	<p>
	If the spell checker has any suggestions for the misspelled word, it will present the suggestions in a
	drop-down list.  If not, it provides a text field for you to enter your own correction.  If a drop-down
	list does not include the spelling you wish to have, then push \"Back\" and make the change to your
	original document.
	<center>
	<hr width=75%>
	<b>Please make changes below:</b>
	</center>
	<p>
	<form action=spell method=post>
	<input type=hidden name=merge_p value=1>
	<input type=hidden name=merge_text value=\"$processed_text\">
	<input type=hidden name=num_errors value=$error_num>
	[export_entire_form]
        [export_form_vars var_to_spellcheck merge_text]
	"
	
	regsub -all "\r\n" $formtext "<br>" formtext_to_display
	ns_write "
	$formtext_to_display
	<p>
	<center>
	<input type=submit value=\"Submit\">
	</form>
	</center>
	<hr width=75%>
	If you like, you can add any words that the spell checker caught to the spelling dictionary.  This will
	prevent the spell checker from catching them in the future.
	<p>
	<ul>
	"
	
	set just_the_errwords [list]
	foreach err $errors {
	    lappend just_the_errwords [lindex $err 2]
	}

	foreach errword [spell_sorted_list_with_unique_elements $just_the_errwords] {
	    ns_write "<form method=post action=spelling-dictionary-add-to>[export_form_vars errword]<li><input type=submit value=\"Add\"> $errword</form><p>"
	}
	ns_write "</ul>
	<p>
	[ad_footer]"
	
    }
    
} 


# an "if" instead of an "elseif" because the above clause may set merge_p to 1
if { $merge_p != "" && $merge_p } {
    set target_url [ns_set get $form target_url]
    ns_set delkey $form target_url

    if { ![info exists error_free_p] } {
	set merge_text [ns_set get $form merge_text]
    } else {
	set merge_text $processed_text
    }
    set num_errors [ns_set get $form num_errors]
    ns_set delkey $form merge_text
    ns_set delkey $form num_errors
    ns_set delkey $form var_to_spellcheck

    for {set i 0} {$i < $num_errors} {incr i} {
	regsub "\#$i\#" $merge_text [ns_set get $form "error_$i"] merge_text
	ns_set delkey $form "error_$i"
    }

#    set merge_text [ns_urlencode $merge_text]

#    ns_returnredirect "$target_url?$var_to_spellcheck=$merge_text&[export_url_vars $form]"

    ReturnHeaders

    ns_write "[ad_header "Spell Checker"]
    <h2>Spell Checker</h2>
    <hr>
    "

    if { [info exists error_free_p] } {
	ns_write "Your document contains 0 spelling errors.  "
    } else {
	ns_write "Here is the final document with any spelling corrections included.  "
    }

    ns_write "Please confirm that you are satisfied 
    with it.  If not, push your browser's \"Back\" button to go back and make changes.
    <form method=post action=\"$target_url\">
    [export_entire_form]
    <input type=hidden name=$var_to_spellcheck value=\"$merge_text\">
    <center>
    <input type=submit value=\"Confirm\">
    </center>
    <hr width=75%>
    <pre>$merge_text</pre>
    <p>
    [ad_footer]
    "
    return
}

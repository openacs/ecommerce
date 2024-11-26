# spelling-dictionary-add-to.tcl,v 3.0 2000/02/06 03:54:46 ron Exp
set_the_usual_form_variables
#errword

set db [ns_db gethandle]

if [catch {ns_db dml $db "insert into ispell_words (ispell_word) values ('$QQerrword')"}] {
    ad_return_error "Unable to add word" "We were unable to add $errword to the dictionary.  It is probably because somebody else tried to add the same word at the same time to the dictionary (words in the dictionary must be unique)."
    return
}

# Now that Oracle has handled the transaction control of adding words to the dictionary, bash the
# ispell-words file.  Jin has promised me (eveander) that ispell-words won't become corrupted because,
# since one chunk is only to be added to the file at a time, it is impossible for the chunks to
# become interspersed. 

set ispell_file [open "[ns_server pagedir]/tools/ispell-words" a]

# ispell-words will be of the form: one word per line, with a newline at the end (since -nonewline is not specified)
puts $ispell_file "$errword"

ReturnHeaders
ns_write "[ad_header "$errword added"]
<h2>$errword has been added to the spelling dictionary</h2>
<hr>
Please push \"Back\" to continue with the spell checker.
[ad_footer]
"

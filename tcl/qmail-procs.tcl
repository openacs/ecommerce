ad_library {
    qmail support procs.

    @author Jin Choi
    @creation-date 1999-01-15
    @cvs-id $Id$
}

ad_proc qmail {to from subject body {extraheaders {}}} {
    procedure for sending mail by directly injecting it into the qmail system.

    @author jsc 
    @creation-date 1999-01-15
} {
    set msg "To: $to\nFrom: $from\nSubject: $subject\nDate: [ns_httptime [ns_time]]"
    ## Insert extra headers, if any
    if ![string match "" $extraheaders] {
	set size [ns_set size $extraheaders]
	for {set i 0} {$i < $size} {incr i} {
	    append msg "\n[ns_set key $extraheaders $i]: [ns_set value $extraheaders $i]"
	}
    }
    
    append msg "\n\n$body"

    # Specify the envelope sender address so that we don't see the default
    # Return-Path of anonymous@host.domain
    if [regexp {.*<(.*)>} $from ig address] {
	set from $address
    }
    
    # -h says use header fields for recipients
    set qmail_pipe [open "| /var/qmail/bin/qmail-inject -h -f$from" "w"]
    puts -nonewline $qmail_pipe $msg
    close $qmail_pipe
}

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
    if { ![empty_string_p $to] } {
        ns_sendmail $to $from $subject $body $extraheaders
    } else {
        ns_log Notice "qmail-procs.tcl: Warning, requested to send an email without an email address. subject=$subject"
    }
}

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
    ns_sendmail $to $from $subject $body $extraheaders
}

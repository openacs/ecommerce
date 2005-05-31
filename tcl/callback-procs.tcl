# packages/ecommerce/tcl/callback-procs.tcl

ad_library {
    
    
    
    @author Roel Canicula (roelmc@pldtdsl.net)
    @creation-date 2005-05-19
    @arch-tag: 1d7b6804-78fd-4c1e-bb7c-e52ff8f31692
    @cvs-id $Id$
}

namespace eval ecommerce {}

ad_proc -callback ecommerce::after-checkout {
    -user_id
    -product_id
    -price
} {} {}
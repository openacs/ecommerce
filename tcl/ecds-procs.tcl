ad_library {

    Customization utilities for maintaining product data in ecommerce module.

    @creation-date  Aug 2007

    #default import procs requires these ec_custom_product_field_values fields defined as text types of length indicated.
    #use vendorwebuid for referencing website resources, when vendorsku etc are not directly referenced (such as another site using product_id)
    unitofmeasure 200
    brandname 200
    brandmodelnumber 200
    minshipqty 200
    shortdescription 4000
    longdescription 4000
    salesdescription 4000
    webcomments 4000
    productoptions 4000
    unspsccode 200
    vendorsku 200
    vendorabbrev 200
vendorcost numeric
vendorwebuid 4000
}

ad_proc -private ecds_is_natural_number {
    value
} {
    answers question: is value a natural counting number (non-negative integer)?
    returns 0 or 1
} {
    set is_natural [regexp {^(0*)(([1-9][0-9]*|0))$} $value match zeros value]
    return $is_natural
}

ad_proc -private ecds_remove_from_list {
    value value_list
} {
    removes multiple of a specific value from a list
    returns list without the passed value
} {

    set value_indexes [lsearch -all -exact $value_list $value]
    while { [llength $value_indexes] > 0 } {
        set next_index [lindex $value_indexes 0]
        set value_list [lreplace $value_list $next_index $next_index]
        set value_indexes [lsearch -all -exact $value_list $value]
    }
    return $value_list
}


ad_proc -private ecds_sku_from_brand {
    brand_name
    brand_model_number
    {sku ""}
    {separator "-"}
} {
    returns a normalized sku, given brand info, or sku if it exists
    @brand_name@
    @brand_model_number@
    @sku@ optional
} {
    if { [string length $sku] == 0 } {
        set product_sku [string trim [string tolower $brand_model_number]]

        set brandname_width 21
        set brandname_len_limit 19
#ns_log Notice "brand_name $brand_name"
        regsub -all -- { and } $brand_name {-} brandname_new
#ns_log Notice "1brandname_new $brandname_new"
        regsub -all -- {\/} $brandname_new {} brandname_new
#ns_log Notice "2brandname_new $brandname_new"
        regsub -all -- { } $brandname_new {} brandname_new
#ns_log Notice "3brandname_new $brandname_new"
        regsub -all -- {&} $brandname_new {} brandname_new
#ns_log Notice "4brandname_new $brandname_new"
        regsub -all -- {\.} $brandname_new {} brandname_new
#ns_log Notice "5brandname_new $brandname_new"
        if { [string length $brandname_new] > $brandname_width } {
            set brandname_end [expr { [string last " " [string range $brandname_new 0 $brandname_width] ] - 1 } ]
            if { $brandname_end < 0 } {
                set brandname_end $brandname_len_limit
            }
            set brandname_new [string range $brandname_new 0 $brandname_end ]
            regsub {[^a-zA-Z0-9]+\.\.} $brandname_new {} brandname_new
        }
#ns_log Notice "6brandname_new $brandname_new"
        regsub -all -- { } $brandname_new {-} brandname_new
#ns_log Notice "7brandname_new $brandname_new"
        set brandname_new [string trim [string tolower $brandname_new]]
#ns_log Notice "8brandname_new $brandname_new"
        set sku "${brandname_new}${separator}${product_sku}"
        regsub -all -- {[\-]+} $sku {-} sku
#ns_log Notice "returning sku $sku"
    }
    return $sku
}


ad_proc -private ecds_base_shipping_price_from_order_value {
    total_price
    base_ship_price
} {
    returns the value based shipping price, based on the value of the total price of items in the cart
    and perhaps the value of any existing shipping price
    this value based shipping price gets added to the base_shipping_price
    this is ignored when using a shipping gateway
} {
    # example 1, shipping increases with price
    # set value_based_shipping [expr pow($total_price,0.5) ]

   #example 2, free shipping for orders over $130, and shipping amount decreases with price
   # add a decreasing shipping and handling amount for items that do not have much profit margin (to cover shipping)
   # if price is large enough (say over 130), we assume we are able to cover shipping out of profit)
   # lets assume we want to have at least 5usd shipping and handling
  #  if { $total_price <= 130 } {
  #      set value_based_shipping \[expr { ( -5 * $total_price / 130 ) + 5 } \]
  #  } else {
   #     set value_based_shipping 0
   # }

   # example 3 using 1/x multiplier
    set multiplier [f::max [expr { ( 15. / ( $total_price + 4 ) ) - 0.05 } ] 0]
    
    set value_based_shipping [expr { $total_price * $multiplier } ]
    return $value_based_shipping
}


ad_proc -private ecds_get_url {
    url
    {refresh_period "80 days ago"}
} {
    returns page content of url, caches data so as to not clobber other server if page request is newer than refresh_period, 
    where refresh_period is a tcl based relative time reference
} {
    set url_cache_dir [parameter::get -parameter CacheDataDirectory -default ecds-url-cache]
    # if the page has been retrieved previously, use the cached version
    
    db_0or1row check_url_history {select url,cache_filepath ,last_update,flags from ecds_url_cache_map where url = :url}

    # if cache is within refresh period (cache time is > refresh time), get the cached version 
    if { [info exists last_update] && [clock scan [string range $last_update 0 18]] > [clock scan $refresh_period] } {
        # get the page from filepath
        # ns_log Notice "ecds_get_url: getting page from filepath"
        # set filepathname [file join [acs_root_dir] $url_cache_dir $base_url]
        set filepathname $cache_filepath
        # file open
        if { [catch {open $filepathname r} fileId]} {
            ns_log Error "ecds_get_url: file $filepathname not found."
            ad_script_abort    
        } else {
            # read file
            while { ![eof $fileId] } {
                gets $fileId line_of_file
                append page $line_of_file
            }
            close $fileId
        }
    
    } else {
        # get file from url
	ns_log Notice "ecds_get_url: $url waiting 20 seconds before trying, in case we recently grabbed a url"
			after 20000

        if { [catch {set get_id [ns_http queue -timeout 65 $url]} err ]} {
            set page $err
            ns_log Error "ecds_get_url: url=$url error: $err"
        } else {
            ns_log Notice "ecds_get_url: ns_httping $url"
            set flags ""
# removed -timeout "30" from next statment, because it is unrecognized for this instance..
            if { [catch { ns_http wait -result page -status status $get_id } err2 ]} {
                ns_log Error "ecds_get_url: ns_http wait $err2"
            }
    
            if { ![info exists status] || $status ne "200" } {
                # no page info returned, just return error
                if { ![info exists status] } {
                    set status "not exists"
                }
                set page "Error: url timed out with status $status"
                ns_log Notice $page
            } else {
                #ns_log Notice "ecds_get_url: adding page to file cache"
                #put page into file cache
                set base_url [string range $url 7 end]
                set filepathname [file join [acs_root_dir] $url_cache_dir $base_url]
                # if ec_assert_directory doesnot work here, try replacing ns_mkdir with 'file mkdir' or
                # make the ec_asser_directory recursive
                set filepath [file dirname $filepathname]
                ec_assert_directory $filepath
                if { [file exists ${filepathname} ] } {
                    file delete ${filepathname}
                }
                if { [catch {open $filepathname w} fileId]} {
                    ns_log Error "ecds_get_url: unable to write to file $filepathname"
                    ad_script_abort
                } else {
                    if { ![string match -nocase {*.[jgpb][pinm][egfp]} $url ] } {
                        #ns_log Notice "ecds_get_url: compressing content of $url"
                        # strip extra lines and funny characters
                        regsub -all -- {[\f\e\r\v\n\t]} $page { } oneliner
                        # strip extra spaces 
                        regsub -all -- {[ ][ ]*} $oneliner { } oneliner2
                        # could strip SCRIPT tags here to save space, but that content might contain valuable string fragments
                        set page $oneliner2
                        puts $fileId $page
                        ns_log Notice "ecds_get_url: writing $filepathname to ecds-cache"
                        close $fileId

                    } else {
                        # this is an image, prepare to send binary
                        # following doesn't work for aolserver 4.0x, so we use alternate method
                        # fconfigure $fileId -translation binary
                        #puts $fileId $page

                        # given $image_url                                                                                                  
                        set file_dir_path [file dirname $filepathname]
                        ec_assert_directory $file_dir_path
                        ns_log Notice "ecds_get_url(L215): wget -q -nc -t 1 -P${file_dir_path} -- ${image_url}"
                        if { [catch {exec /usr/local/bin/wget -q -nc -t 1 -P${file_dir_path} -- ${image_url} } errmsg ] } {
                            set testita $errmsg
                        } else {
                            set testita $filepathname
                            ns_log Notice "ecds_get_url: wgetting $image_url (waiting 20 sec to ck)"
                            # wait 20 sec to see if file is gotten
                            after 20000
                            if { [file exists $filepathname] } {
                                # success! file gotten, now we can process it
                            } else {
                                ns_log Warning "file $filepathname does not exist after attempt to fetch from $url"
                            }
                            
                        }


                        ns_log Notice "ecds_get_url: writing $filepathname to ecds-cache"
                        close $fileId
                    }
                    # log cache into map
                    if { [db_0or1row check_url_in_cache {select url from ecds_url_cache_map where url = :url}] } {
                        db_dml update_cache {update ecds_url_cache_map set cache_filepath =:filepathname, last_update=now(), flags=:flags where url=:url}
                    } else {
                        db_dml insert_to_cache {insert into ecds_url_cache_map
                            (url,cache_filepath,last_update,flags)
                            values (:url,:filepathname,now(), :flags) }
                    }
    
                }
            }
        }
    }
    return $page
}

ad_proc -private ecds_get_image_from_url {
    url
    {refresh_period "80 days ago"}
} {
    returns filepathname of local copy of image at url
    caches data so as to not clobber other server if page request is newer than refresh_period, 
    where refresh_period is a tcl based relative time reference
} {
    if { [string length $url] > 0 } {
        set status "OK"
        # if the page has been retrieved previously, just get the filepath
        set url_cache_dir [parameter::get -parameter CacheDataDirectory -default ecds-url-cache]
        
        db_0or1row check_url_history {select cache_filepath,last_update,flags from ecds_url_cache_map where url = :url}
        
        if { [info exists last_update] && [clock scan [string range $last_update 0 18]] > [clock scan $refresh_period] } {
            # set the filepath
            #        set filepathname [file join [acs_root_dir] $url_cache_dir $cache_filepath]
            set filepathname $cache_filepath   
        } else {
            
            #fetch image, put into cache directory tree
            # 1 means use wget because aolserver4.0.10 ns_http does not work for images.
            if { 1 } {
                # given $url                                                                                                  
                set base_url [string range $url 7 end]
                set filepathname [file join [acs_root_dir] $url_cache_dir $base_url]
                set filepath [file dirname $filepathname]
                ec_assert_directory $filepath
                if { [file exists ${filepathname} ] } {
                    file delete ${filepathname}
                }
                if { [catch {exec /usr/local/bin/wget -q -nc -T 20 -t 1 -P${filepath} -- $url} errmsg ] } {
                    ns_log Error "ecds_get_image_from_url(L279): wget -q -nc -T 20 -t 1 -P${filepath} -- $url ERROR MESSAGE: $errmsg"
                    set status "ERROR"
                } else {
                    # wait 20 sec to see if file is gotten
                    ns_log Notice "ecds_get_image_from_url: wgetting $url (waiting 20 sec to check)"
                    after 20000
                    if { [file exists $filepathname] } {
                        # success! file gotten, now we can process it
                        set flags ""
                        # log cache into map
                        if { [db_0or1row check_url_in_cache {select url from ecds_url_cache_map where url = :url}] } {
                            db_dml update_cache {update ecds_url_cache_map set cache_filepath =:filepathname, last_update=now(), flags=:flags where url=:url}
                        } else {
                            db_dml insert_to_cache {insert into ecds_url_cache_map
                                (url,cache_filepath,last_update,flags)
                                values (:url,:filepathname,now(), :flags) }
                        }
                        
                    } else {
                        ns_log Error "ecds_get_image_from_url: file $filepathname does not exist after attempt to fetch from $url"
                        set status "ERROR"
                    }
                    
                }
                
                
            } else {
                # ns_http does not work for aolserver 4.0.10, using wget instead
                # more info at: http://openacs.org/forums/message-view?message_id=1200269
                # if aolserver4.5, should work to use:
                
                if { [catch {set get_id [ns_http queue GET $url]} err ]} {
                    set page $err
                    ns_log Error "ecds_get_image_from_url: $error"
                } else {
                    ns_log Notice "ecds_get_image_from_url: ns_httping $url"
                    set flags ""
                    set status [ns_http wait $get_id page]
                    
                    if { $page eq "timeout" || [string length $page] < 20 } {
                        # no page info returned, just return error
                        set page "Error: url timed out"
                        set filepathname ""
                        set status "ERROR"
                    } else {
                        #ns_log Notice "ecds_get_url: adding page to file cache"
                        #put page into file cache
                        set base_url [string range $url 7 end]
                        set filepathname [file join [acs_root_dir] $url_cache_dir $base_url]
                        set filepath [file dirname $filepathname]
                        ec_assert_directory $filepath
                        if { [file exists ${filepathname} ] } {
                            file delete ${filepathname}
                        }
                        if { [catch {open $filepathname w} fileId]} {
                            ns_log Error "ecds_get_image_from_url: unable to write to file $filepathname"
                            set status "ERROR"
                        } else {
                            # this is an image, prepare to save binary
                            fconfigure $fileId -translation binary
                            puts $fileId $page
                            #ns_log Notice "ecds_get_url: writing $filepathname with content: $page"
                            close $fileId
                            # log cache into map
                            if { [db_0or1row check_url_in_cache {select url from ecds_url_cache_map where url = :url}] } {
                                db_dml update_cache {update ecds_url_cache_map set cache_filepath =:filepathname, last_update=now(), flags=:flags where url=:url}
                            } else {
                                db_dml insert_to_cache {insert into ecds_url_cache_map
                                    (url,cache_filepath,last_update,flags)
                                    values (:url,:filepathname,now(), :flags) }
                            }
                            
                        }
                    }
                }
            }
        }
        ns_log Notice "ecds_get_image_from_url: status is $status"
        if { $status eq "OK" } { 
            return $filepathname   
        } else { 
            return $status
        }
    } else {
        ns_log Warning "ecds_get_image_from_url: The image url is blank. No image fetched."
        return "ERROR"
    }
}

ad_proc -private ecds_import_image_to_ecommerce {
    product_id
    image_filepathname
} {
  imports an image from the system into ecommerce, returns 1 if works, or 0 if errors
    # this code requires product_id, image_filepathname
} {
    set serious_errors 0
    set convert [ec_convert_path]
    # check imagename
    if { [string match -nocase {*picsn.jpg} $image_filepathname ] || [empty_string_p $image_filepathname] || [string match -nocase *avail* $image_filepathname ] } {
       #  image_filepathname is "notavail.jpg" or picsn.jpg or xl-*
       # do not process
        # remove any old images
        set 2prod [ec_product_file_directory $product_id]
        set product_path [file join [ec_data_directory_mem] [ec_product_directory_mem] $2prod $dirname]
        ec_assert_directory $product_path
        set product_base_pathname [file join $product_path "product*" ]
        foreach match [glob -nocomplain -- $product_base_pathname] {
            ns_log Notice "ecds_import_image_to_ecommerce: unavailable image detected for product_id ${product_id}. Removing existing image $match"
            [file delete $match]
        }

    } else {
        db_1row get_product_dirname "select dirname from ec_products where product_id = :product_id"
        set new_imagetype [string tolower [string range $image_filepathname end-2 end]]

        if { ![string equal $new_imagetype "jpg"] && ![string equal $new_imagetype "gif"] } {
            ns_log Error "ecds_import_image_to_ecommerce: cannot handle non jpg/gif files. image_pathname = ${image_filepathname}"
            ad_script_abort
        }

        set 2prod [ec_product_file_directory $product_id]
        set product_path [file join [ec_data_directory_mem] [ec_product_directory_mem] $2prod $dirname]
        ec_assert_directory $product_path
        set product_base_pathname [file join $product_path "product." ]
        set product_image_location "${product_base_pathname}${new_imagetype}" 

        # update the product image
        if { [file exists "${product_base_pathname}jpg" ] } {
            file delete "${product_base_pathname}jpg"
        }
        if { [file exists "${product_base_pathname}gif" ] } {
            file delete "${product_base_pathname}gif"
        }

        if { [catch {file copy $image_filepathname $product_image_location} errmsg] } {
            ns_log Warning "ecds_import_image_to_ecommerce (50): while creating product image: $errmsg"
            set serious_errors 1
        } else {
            # create thumbnail
            set use_both_param_dimensions [parameter::get -parameter ThumbnailSizeOuterlimits]
            set thumbnail_width [parameter::get -parameter ThumbnailWidth]
            set thumbnail_height [parameter::get -parameter ThumbnailHeight]
            if { $use_both_param_dimensions && !$serious_errors } {
                set convert_dimensions "${thumbnail_width}x${thumbnail_height}>"
            } elseif { !$serious_errors } {
                if { [string length $thumbnail_width] == 0 } {
                    if { [string length $thumbnail_height] == 0 } {
                        set convert_dimensions "100x10000"
                    } else {
                        set convert_dimensions "10000x${thumbnail_height}"
                    }
                } else {
                    set convert_dimensions "${thumbnail_width}x10000"
                }
            }
            set system_url [parameter::get -package_id [ad_acs_kernel_id] -parameter SystemURL]
            set system_name [parameter::get -package_id [ad_acs_kernel_id] -parameter SystemName]
            set image_comment "from $system_url $system_name"
            set perm_thumbnail_filename [file join $product_path "product-thumbnail.jpg"]
            
            if { [catch {exec $convert -geometry $convert_dimensions -comment \"$image_comment\" $product_image_location $perm_thumbnail_filename} errmsg ]} {
                ns_log Notice "ecds_import_image_to_ecommerce: while creating thumbnail: $errmsg"
                set serious_errors 1
            }
        }
    }
    return $serious_errors
}

ad_proc -private ecds_get_contents_from_tag {
    start_tag
    end_tag
    page
    {start_index 0}
} {
    Returns content of an html/xml or other bracketing tag that is uniquely identified within a page fragment or string.
    helps pan out the golden nuggets of data from the waste text when given some garbage with input for example
} {
    set tag_contents ""
    set start_col [string first $start_tag $page $start_index]
    set end_col [string first $end_tag $page $start_col]
    if { $end_col > $start_col && $start_col > -1 } {
        set tag_contents [string trim [string range $page [expr { $start_col + [string length $start_tag] } ] [expr { $end_col -1 } ]]]
    } else {
        set starts_with "${start_tag}.*"
        set ends_with "${end_tag}.*"
        if { [regexp -- ${starts_with} $page tag_contents ]} {
            if { [regexp -- ${ends_with} $tag_contents tail_piece] } {
                set tag_contents [string range $tag_contents 0 [expr { [string length $tag_contents] - [string length $tail_piece] - 1 } ] ]
            } else {
                ns_log Notice "Warning no contents for tag $start_tag"
                set tag_contents ""
            }
        }
    }
    return $tag_contents
}

ad_proc -private ecds_get_contents_from_tags_list {
    start_tag
    end_tag
    page
} {
    Returns content (as a list) of all occurances of an html/xml or other bracketing tag that is somewhat uniquely identified within a page fragment or string.
    helps pan out the golden nuggets of data from the waste text when given some garbage with input for example
} {
    set start_index 0
    set tag_contents_list [list]
    set start_tag_len [string length $start_tag]
    set start_col [string first $start_tag $page 0]
    set end_col [string first $end_tag $page $start_col]
    set tag_contents [string range $page [expr { $start_col + $start_tag_len } ] [expr { $end_col - 1 } ]]
    while { $start_col != -1 && $end_col != -1 } {
        lappend tag_contents_list [string trim $tag_contents]

        set start_index [expr { $end_col + 1 }]
        set start_col [string first $start_tag $page $start_index]
        set end_col [string first $end_tag $page $start_col]
        set tag_contents [string range $page [expr { $start_col + $start_tag_len } ] [expr { $end_col - 1 } ]]
    }
    return $tag_contents_list
}

ad_proc -private ecds_remove_tag_contents {
    start_tag
    end_tag
    page
} {
    Returns everything but the content between start_tag and end_tag (as a list) 
    of all occurances on either side of an html/xml or other bracketing tag 
    that is somewhat uniquely identified within a page fragment or string.
    This is handy to remove script tags and < ! - - web comments - - > etc
    helps pan out the golden nuggets of data from the waste text when given some garbage with input for example
} {
    # start and end refer to the tags and their contents that are to be removed
    set start_index 0
    set tag_contents_list [list]
    set start_tag_len [string length $start_tag]
    set end_tag_len [string length $end_tag]
    set start_col [string first $start_tag $page 0]
    set end_col [string first $end_tag $page $start_col]
    # set tag_contents [string range $page 0 [expr { $start_col - 1 } ] ]
    while { $start_col != -1 && $end_col != -1 } {
        set tag_contents [string range $page $start_index [expr { $start_col - 1 } ] ]
        lappend tag_contents_list [string trim $tag_contents]

        # start index is where we begin the next clip        
        set start_index [expr { $end_col + $end_tag_len } ]
        set start_col [string first $start_tag $page $start_index]
        set end_col [string first $end_tag $page $start_col]
        # and the new clip ends at the start of the next tag
    }
    # append any trailing portion
    lappend tag_contents_list [string range $page $start_index end]
    set remaining_contents [join $tag_contents_list ""]
    return $remaining_contents
}


ad_proc -private ecds_convert_html_list_to_tcl_list {
    html_list
} {
    converts a string containing an html list to a tcl list
    Assumes there are no embedded sublists, and strips remaining html
} {
    set draft_list $html_list

    #we standardize the start and end of the list, so we know where to clip

    if { [regsub -nocase -- {<[ou][l][^\>]*>} $draft_list "<ol>" draft_list ] ne 1 } {
        # no ol/ul tag, lets create the list container anyway
        set draft_list "<ol> ${draft_list}"

    } else {
        # ol/ul tag exists, trim garbage before list
        set draft_list [string range $draft_list [string first "<ol>" $draft_list ] end ]
    }

    if { [regsub -nocase -- {</li>[ ]*</[ou]l[^\>]*>} $draft_list "</li></ol>" draft_list ] ne 1 } {
        # end list tag may not exist or is not in standard form
        if { [regsub -nocase -- {</[ou]l[^\>]*>} $draft_list "</li></ol>" draft_list ] ne 1 } {
            # assume for now that there was no end li tag before the list (bad html)
        } else {
            # no ol/ul list tag, assume no end </li> either?
            append draft_list "</li></ol>"
        }
    }

    # end ol tag exists, trim garbage after list
    # choosing the last end list tag in case there is a list in one of the lists
    set draft_list [string range $draft_list 0 [expr { [string last "</ol>" $draft_list ] + 4} ] ]

    # simplify li tags, with a common delimiter
    regsub -nocase -all -- {<li[^\>]*>} $draft_list {|} draft_list
    # remove other html tags

    set draft_list [ecds_webify $draft_list]

    # remove excess spaces
    regsub -all -- {[ ]+} $draft_list " " draft_list
    set draft_list [string trim $draft_list]

    # remove excess commas and format poorly placed ones
    regsub -all -- {[ ],} $draft_list "," draft_list

    regsub -all -- {[,]+} $draft_list "," draft_list

    # put colons in good form
    regsub -all -- {[ ]:} $draft_list ":" draft_list

    regsub -all -- {:,} $draft_list ":" draft_list
    # remove : in cases where first column is blank, ie li should not start with a colon

    regsub -all -- {\|:} $draft_list {|} draft_list

    set tcl_list [split $draft_list {|}]
    # first lindex will be blank, so remove it
    set tcl_list [lrange $tcl_list 1 end]
#ns_log Notice "ecds_convert_html_list_to_tcl_list: tcl_list $tcl_list"
    return $tcl_list
}

ad_proc -private ecds_convert_html_table_to_list {
    html_string
    {list_style ul}
} {
    converts a string containing an html table to an html list
    assumes first column is a heading (with no rows as headings), and remaining columns are values
    defaults to li list style, should return list in good html form even if table is not quite that way
} {

    if { [regsub -nocase -- {<table[^\>]*>} $html_string "<${list_style}>" draft_list ] ne 1 } {
        # no table tag, lets create the list container anyway
        set draft_list "<${list_style}> ${html_string}"
    } else {
        # table tag exists, trim garbage before list
        set draft_list [string range $draft_list [string first "<${list_style}>" $draft_list ] end ]
    }

    if { [regsub -nocase -- {</tr>[ ]*</table[^\>]*>} $draft_list "</li></${list_style}>" draft_list ] ne 1 } {
        # end table tag may not exist or is not in standard form
        if { [regsub -nocase -- {</table[^\>]*>} $draft_list "</li></${list_style}>" draft_list ] ne 1 } {
            # assume for now that there was no end tr tag before the table (bad html)
        } else {
            # no table tag, assume no end </tr> either?
            append draft_list "</li></${list_style}>"
        }
    }

    # end table tag exists, trim garbage after list
    # choosing the last end list tag in case there is a list in one of the table cells
    set draft_list [string range $draft_list 0 [expr { [string last "</${list_style}>" $draft_list ] + 4} ] ]

    # simplify tr and td tags, but do not replace yet, because we want to use them for markers when replacing td tags
    regsub -nocase -all -- {<tr[^\>]+>} $draft_list "<tr>" draft_list
    regsub -nocase -all -- {</tr[^\>]+>} $draft_list "</tr>" draft_list
    regsub -nocase -all -- {<td[^\>]+>} $draft_list "<td>" draft_list
    regsub -nocase -all -- {</td[^\>]+>} $draft_list "</td>" draft_list

    # clean out other content junk tags
    regsub -nocase -all -- {<[^luot\/\>][^\>]*>} $draft_list "" draft_list
    regsub -nocase -all -- {</[^luot\>][^\>]*>} $draft_list "" draft_list

    set counterA 0
    while { [string match -nocase "*<tr>*" $draft_list ] } {

       if { [incr counterA ] > 300 } {
           ns_log Error "convert_html_table_to_list, ref: counterA detected possible infinite loop."
           doc_adp_abort
        }
        # get row range
        set start_tr [string first "<tr>" $draft_list ]
        set end_tr [string first "</tr>" $draft_list ]

        # make sure that the tr end tag matches the current tr tag
        if { $end_tr == -1 } {
            set next_start_tr [string first "<tr>" $draft_list [expr { $start_tr + 4 } ] ]
        } else {
            set next_start_tr [string first "<tr>" $draft_list $end_tr ]
        }

        regsub -- {<tr>} $draft_list "<li>" draft_list

        if { $end_tr < $next_start_tr && $end_tr > -1 } {
            regsub -- {</tr>} $draft_list "     " draft_list
            # common sense says we replace </tr> with </li>, but then there may be cases missing a </tr>
            # and if so, we would have to insert a </li> which would mess up the position values for use
            # later on. Instead, at the end, we convert <li> to </li><li> and take care of the special 1st and last cases
        } 

        # we are assuming any td/tr tags occur within the table, since table has been trimmed above
        set start_td [string first "<td>" $draft_list ]
        set end_td [string first "</td>" $draft_list ]
        set next_start_td [string first "<td>" $draft_list [expr { $start_td + 3 } ] ]

        if { $next_start_td == -1 || ( $next_start_td > $next_start_tr && $next_start_tr > -1 )} {
            # no more td tags for this row.. only one column in this table

        } else {
            # setup first special case of first column
            # replacing with strings of same length to keep references current throughout loops
            set draft_list [string replace $draft_list $start_td [expr { $start_td + 3 } ] "    " ]

            if { $end_td < $next_start_tr && $end_td > -1 } {
                # there is an end td tag for this td cell, replace with :
                set draft_list [string replace $draft_list $end_td [expr { $end_td + 4 } ] ":    " ]

            } else {
                # insert special case, just prior to new td tag
                set draft_list "[string range ${draft_list} 0 [expr { ${next_start_td} - 1 } ] ]: [string range ${draft_list} ${next_start_td} end ]"
                if { $next_start_tr > 0 } {
                    incr next_start_tr 2
                }
            }
        }

        # process remaining td cells in row, separating cells by comma
        set column_separator "    "
        if { $next_start_tr == -1 } {
            set end_of_row [string length $draft_list ]
        } else {
            set end_of_row [expr { $next_start_tr + 3 } ]
        }

        set columns_to_convert [string last "<td>" [string range $draft_list 0 $end_of_row ] ]
        set counterB 0
        while { $columns_to_convert > -1 } {

            if { [incr counterB ] > 200 } {
                ns_log Error "convert_html_table_to_list, ref: counterB detected possible infinite loop."
                doc_adp_abort
            }

            set start_td [string first "<td>" $draft_list ]
            set end_td [string first "</td>" $draft_list ]
            set next_start_td [string first "<td>" $draft_list [expr { $start_td + 3 } ] ]

            if { $next_start_td == -1 } {
                # no more td tags for all rows.. still need to process this one.
                set columns_to_convert -1
                set draft_list [string replace $draft_list $start_td [expr { $start_td + 3 } ] $column_separator ]

            } elseif { ( $next_start_td > $next_start_tr && $next_start_tr > -1 ) } {
                # no more td tags for this row..
                set columns_to_convert -1

            } else {
                # add a comma before the value, if this is not the first value
                set draft_list [string replace $draft_list $start_td [expr { $start_td + 3 } ] $column_separator ]

            }

            if { $end_td > -1 && ( $end_td < $next_start_td || $next_start_td == -1 ) } {
                # there is an end td tag for this td cell, remove it
                regsub -- {</td>} $draft_list "" draft_list
            }

            set column_separator ",    "
            # next column
        }


        # next row
    }

    # clean up list, add </li>
    regsub -all -- "<li>" $draft_list "</li><li>" draft_list
    # change back first case
    regsub -- "</li><li>" $draft_list "<li>" draft_list
    # a /li tag is already included with the  list container end tag

    # remove excess spaces
    regsub -all -- {[ ]+} $draft_list " " draft_list

    # remove excess commas and format poorly placed ones
    regsub -all -- {[ ],} $draft_list "," draft_list
    regsub -all -- {[,]+} $draft_list "," draft_list

    # put colons in good form
    regsub -all -- {[ ]:} $draft_list ":" draft_list
    regsub -all -- {:,} $draft_list ":" draft_list
    # remove : in cases where first column is blank, ie li should not start with a colon
    regsub -all -- {<li>:} $draft_list "<li>" draft_list

   return $draft_list
}

ad_proc -private ecds_update_ec_category_map {
    subcategory_id
    product_id
    remove_multiple_categories
    user_id
    ip
} {
    updates the mapping of a category and subcategory to a product_id, category_id determined from subcategory_id
} {

    # verify subcategory_id is valid
    db_0or1row get_category_id_from_subcategory_id "select category_id from ec_subcategories where subcategory_id = :subcategory_id"
    if { [info exists category_id] && $category_id > 0 && [info exists subcategory_id] && $subcategory_id > 0 } {

        # identify cases where item is in other subcategory_id of same category_id
        set old_subcategory_id_list [db_list get_oldsubcategory_id_from_category_id "select subcategory_id as old_subcategory_id from ec_subcategory_product_map where product_id = :product_id and category_id = :category_id"]

        if { [llength $old_subcategory_id_list] == 0 } {
            # no previous mappings exist
            ns_log Notice "ecds_update_ec_category_map (L457): category mapping does not exist for product_id $product_id , subcategory_id $subcategory_id , adding..."   
            if { [catch {db_dml ecds_subcategory_insert "insert into ec_subcategory_product_map (product_id, subcategory_id, publisher_favorite_p, last_modified, last_modifying_user, modified_ip_address) values (:product_id, :subcategory_id, 'f', now(), :user_id, :ip)"} errmsg] } {
                #error, probably already loaded this one
            } 

        } elseif { [llength $old_subcategory_id_list] > 0 } {
            # previous mappings exist
            # is one of them the mapping we want to add?
            set mapping_already_exists [lsearch -exact -integer $old_subcategory_id_list $subcategory_id]
            if { $mapping_already_exists == -1 && $remove_multiple_categories == 1 } {
                # update the first existing one
                set old_subcategory_id [lindex $old_subcategory_id_list 0]
                db_dml update_subcategory_id_in_subcategory_map "update ec_subcategory_product_map set subcategory_id = :subcategory_id, last_modified = now(), last_modifying_user = :user_id, modified_ip_address = :ip where product_id = :product_id and category_id = :category_id and subcategory_id = :old_subcategory_id"
                # remove first item from list
                set old_subcategory_id_list [lrange $old_subcategory_id 1 end]

            } elseif { $mapping_already_exists == -1 && $remove_multiple_categories == 0 } {
                ns_log Notice "ecds_update_ec_category_map (L474): category mapping does not exist for product_id $product_id , subcategory_id $subcategory_id , adding..."   
                if { [catch {db_dml ecds_subcategory_insert "insert into ec_subcategory_product_map (product_id, subcategory_id, publisher_favorite_p, last_modified, last_modifying_user, modified_ip_address) values (:product_id, :subcategory_id, 'f', now(), :user_id, :ip)"} errmsg] } {
                    #error, probably already loaded this one
                }
            }

            if { remove_multiple_categories == 1 } {
                # remove others (skip if old_subcategory_id = subcategory_id )
                foreach existing_subcategory_id $old_subcategory_id_list {
                    # remove old category item
                    if { $existing_subcategory_id != $subcategory_id } {
                        db_dml remove_subcategory_id_from_subcategory_map "delete from ec_subcategory_product_map where category_id = :category_id and product_id = :product_id and subcategory_id = :existing_subcategory_id"
                    }
                }
            }
        }

        # put product_id in category_map if it is not already there
        db_0or1row is_product_id_already_in_category_id "select product_id as product_already_in_cat from ec_category_product_map where product_id = :product_id and category_id = :category_id"
        if { ![info exists product_already_in_cat ] } {         
            # category has not been added either
            # add mapping to the category that owns this subcategory
            if { [catch {db_dml ecds_category_insert "insert into ec_category_product_map (product_id, category_id, publisher_favorite_p, last_modified, last_modifying_user, modified_ip_address) values (:product_id, :category_id, 'f', now(), :user_id, :ip)"} errmsg] } {
                #error, probably already loaded this one
            }
        }


    } else {
        # subcategory_id not valid, ignore request
        ns_log Warning "ecds_update_ec_category_map, invalid subcategory_id $subcategory_id supplied for product_id $product_id "
    } 
}

ad_proc -private ecds_remove_html {
    description
    {delimiter ":"}
} {

    remvoves html and converts common delimiters to something that works in html tag attributes, default delimiter is ':'

} {
    # remove tags
    regsub -all -- "<\[^\>\]*>" $description " " description

    # convert fancy delimiter to one that complies with meta tag values
    regsub -all -- "&\#187;" $description $delimiter description

    # convert bracketed items as separate (delimited) items
    regsub -all -- {\]} $description "" description
    regsub -all -- {\[} $description $delimiter description

    # convert any dangling lt/gt signs to delimiters
    regsub -all -- ">" $description $delimiter description
    regsub -all -- "<" $description $delimiter description

    # remove characters that
    # can munge some meta tag values or how they are interpreted
    regsub -all -- {\'} $description {} description
    regsub -all -- {\"} $description {} description

    # remove html entities, such as &trade; &copy; etc.
    regsub -all -nocase -- {&[a-z]+;} $description {} description

    # filter extra spaces
    regsub -all -- {\s+} $description { } description
    set description "[string trim $description]"

return $description
}

ad_proc -private ecds_remove_attributes_from_html {
    description
} {

    remvoves attributes from html

} {
    # filter extra spaces
    regsub -all -- {\s+} $description { } description
    set description "[string trim $description]"

    # remove attributes from tags
    regsub -all -nocase -- {(<[/]?[a-z]*)[^\>]*(\>)} $description {\1\2} description
    
return $description
}


ad_proc -private ecds_reverse_context_bar_as_text {
    context_bar_text
    {delimiter ":"}
} {

    creates a comma delimited string of the context_bar text in reverse order

} {
    set context_text [ec_remove_html $context_bar]
    set keywords_list [split $context_text $delimiter]
    set len_keywords [llength $keywords_list]
    set max_keywords $len_keywords
    set reverse_context_bar_text [lindex $keywords_list $len_keywords]

    incr len_keywords -1
    for {set i $len_keywords} {$i >= 0 } {incr i -1} {
        append reverse_context_bar_text ", [lindex $keywords_list $i]"
    }
    # remove a leading blank, if it exists
    if { [string range $reverse_context_bar_text 0 1] == ", "} {
        set reverse_context_bar_text "[string range $reverse_context_bar_text 2 end]"
    }
    return $reverse_context_bar_text
}

ad_proc -private ecds_abbreviate {
    phrase
    {max_length {}}
} {
    abbreviates a pretty title or phrase to first word, or to max_length characters if max_length is a number > 0
} {
    set suffix ".."
    set suffix_len [string length $suffix]

    if { [ad_var_type_check_number_p $max_length] && $max_length > 0 } {
        set phrase_len_limit [expr { $max_length - $suffix_len } ]
        regsub -all -- { / } $phrase {/} phrase
        if { [string length $phrase] > $max_length } {
            set cat_end [expr { [string last " " [string range $phrase 0 $max_length] ] - 1 } ]
            if { $cat_end < 0 } {
                set cat_end $phrase_len_limit
            }
            set phrase [string range $phrase 0 $cat_end ]
        append phrase $suffix
            regsub {[^a-zA-Z0-9]+\.\.} $phrase $suffix phrase
        }
        regsub -all -- { } $phrase {\&nbsp;} phrase
        set abbrev_phrase $phrase

    } else {
        regsub -all { .*$} $phrase $suffix abbrev1
        regsub -all {\-.*$} $abbrev1 $suffix abbrev
        regsub -all {\,.*$} $abbrev $suffix abbrev1
        set abbrev_phrase $abbrev1
    }
    return $abbrev_phrase
}

ad_proc -private ecds_thumbnail_dimensions {
    product_id
    {dirname {}}
} {
    returns thumbnail width and height as html attributes or empty string if no image exists
} {
    set thumbnail_dims ""
    set out_auto_path "[acs_root_dir]"
    if { [empty_string_p $dirname] } {
            db_1row get_dirname "select dirname from ec_products where product_id = :product_id"
    }
    set 2prod [ec_product_file_directory $product_id]
    set thumbnail_path [file join [ec_data_directory_mem] [ec_product_directory_mem] $2prod $dirname product-thumbnail.jpg]
    if { [file exists $thumbnail_path] } {
        set thumbnail_size [ns_jpegsize $thumbnail_path]
        set thumbnail_dims "width=\"[lindex $thumbnail_size 0]\" height=\"[lindex $thumbnail_size 1]\" "
    } else {
        ns_log Warning "ecds_thumbnaildimensions: no thumbnail exists for product_id = $product_id"
    }
    return $thumbnail_dims
}

ad_proc -private ecds_webify {
 description
} {
   standardizes and sanitizes some junky data for use in web content
} {
    # need to remove code between script tags and hidden comments
    set description [ecds_remove_tag_contents {<script} {</script>} $description ]
                     set description [ecds_remove_tag_contents {<!--} {-->} $description ]

    regsub -all "<\[^\>\]*>" $description "" description1
    regsub -all "<" $description1 ":" description
    regsub -all ">" $description ":" description1
    regsub -all -nocase {\"} $description1 {} description
    regsub -all -nocase {\'} $description {} description1
    regsub -all -nocase {&[a-z]+;} $description1 {} description
    return $description
}

ad_proc -private ecds_import_product_from_vendor_site {
    vendor
    product_ref_type
    product_ref
} {
   this proc spiders product data from one external webpage and imports or updates product catalog if there are no significant import errors
  @product_ref_type@ should be either "vendor" or "sku" or "product_id"
  @product_ref@ can be either a vendor_sku or ec_products.sku or ec_products.product_id
  @vendor@ is a reference used in defining vendor specific proc names

  An existing product requires ec_custom_product_field_values.vendorsku defined
  vendor_sku is the vendor's sku for the product

  returns product_id of a product, or -1 if there are significant errors
} {

    # check if okay to start / continue this process
    if { [ecds_process_control_check ecds_import_product_from_vendor_site okay_to_start] eq 0 } {
        return -1
    }

    #  have procs defined using the $vendor under separate file ecds-$vendor-procs.tcl
    # which helps with defining code that is shareable from code that is proprietary

  if { [string length $product_ref] > 0 } {
    # filter out invalid characters etc for the proc name substitution
    regsub -all -- {[^a-zA-Z0-9]} $vendor {} vendor
    set vendor [string range $vendor 0 10]

    set valid_import_modes [list update create]
    set sku ""
    ns_log Notice "ecds_import_product_from_vendor_site: working on: $vendor $product_ref_type $product_ref"
    switch -exact -- $product_ref_type {
        vendor {
            db_0or1row get_product_refs_if_product_exists {select a.sku as sku, a.product_id as product_id from ec_products a, ec_custom_product_field_values c where a.product_id = c.product_id and c.vendorsku =:product_ref }
}
        sku {
            db_0or1row get_product_id_vendor_sku_if_product_exists {select c.vendorsku as vendor_sku, a.product_id as product_id from ec_products a, ec_custom_product_field_values c where a.product_id = c.product_id and a.sku =:product_ref }
}
        product_id {
            db_0or1row get_product_sku_vendor_sku_if_product_exists {select a.sku as sku, c.vendorsku as vendor_sku from ec_products a, ec_custom_product_field_values c where a.product_id = c.product_id and a.product_id =:product_ref }
}


    }

    if { [string equal $product_ref_type "vendor"] && [string length $vendor] > 0 } {
        set vendor_sku $product_ref
    }
 
    if { [info exists product_id] && [info exists vendor_sku] } {
        set import_mode "update"
    } elseif { [info exists vendor_sku] } {
        set import_mode "create"
    } else {
        set import_mode "ERROR"
        ns_log Warning "ecds_import_product_from_vendor_site: not enough info to update or create from: vendor $vendor, product_ref_type ${product_ref_type}, ref: ${product_ref}"
    }
    ns_log Notice "ecds_import_product_from_vendor_site: initial import_mode = ${import_mode}"
    if { [lsearch -exact $valid_import_modes $import_mode] > -1 } {
        set url [ecdsii_${vendor}_product_url_from_vendor_sku $vendor_sku]
        set page [ecds_get_url $url]

        # skip if vendor_sku is not referenced on vendor's page
        if { $vendor_sku eq [ecdsii_${vendor}_vendor_sku_from_page $page] } {

            set image_url [ecdsii_${vendor}_product_image_url $page]
            set image_import_location [ecds_get_image_from_url $image_url]

            #ec_custom_product_field_values fields
            set ec_custom_fields_array(unitofmeasure) [ecdsii_${vendor}_units $page]
            if { [string length $ec_custom_fields_array(unitofmeasure)] > 198 } {
                ns_log Warning "ecds_import_product_from_vendor_site: ref. ${product_ref} unitofmeasure too long, the extra clipped is: [string range $ec_custom_fields_array(unitofmeasure) 198 end]"
                set ec_custom_fields_array(unitofmeasure) [string range $ec_custom_fields_array(unitofmeasure) 0 198]
            }
            set brandname [ecdsii_${vendor}_brand_name $page]
            if { [string length $brandname] > 198 } {
                ns_log Warning "ecds_import_product_from_vendor_site: ref. ${product_ref} brandname too long, the extra clipped is: [string range $ec_custom_fields_array(brandname) 198 end]"
                set brandname [string range $brandname 0 198]
            }
            db_0or1row get_normalized_brand_name_from_alt_spelling "select normalized as brand_name from ecds_alt_spelling_map where alt_spelling =:brandname and context='brand'"
            if { [info exists brand_name] } {
                set ec_custom_fields_array(brandname) $brand_name
            } else {
                set ec_custom_fields_array(brandname) $brandname
            }

            set ec_custom_fields_array(brandmodelnumber) [ecdsii_${vendor}_brand_model_number $page]
            if { [string length $ec_custom_fields_array(brandmodelnumber)] > 198 } {
                ns_log Warning "ecds_import_product_from_vendor_site: ref. ${product_ref} brandmodelnumber too long, the extra clipped is: [string range $ec_custom_fields_array(brandmodelnumber) 198 end]"
                set ec_custom_fields_array(brandmodelnumber) [string range $ec_custom_fields_array(brandmodelnumber) 0 198]
            }



            set ec_custom_fields_array(minshipqty) [ecdsii_${vendor}_min_ship_qty $page]
            if { [string length $ec_custom_fields_array(minshipqty)] > 198 } {
                ns_log Warning "ecds_import_product_from_vendor_site: ref. ${product_ref} minshipqty too long, the extra clipped is: [string range $ec_custom_fields_array(minshipqty) 198 end]"
                set ec_custom_fields_array(minshipqty) [string range $ec_custom_fields_array(minshipqty) 0 198]
            }
            set ec_custom_fields_array(shortdescription) [ecdsii_${vendor}_short_description $page]
            if { [string length $ec_custom_fields_array(shortdescription)] > 3998 } {
                ns_log Warning "ecds_import_product_from_vendor_site: ref. ${product_ref} shortdescription too long, the extra clipped is: [string range $ec_custom_fields_array(shortdescription) 3998 end]"
                set ec_custom_fields_array(shortdescription) [string range $ec_custom_fields_array(shortdescription) 0 3998]
            }
            set ec_custom_fields_array(longdescription) [ecdsii_${vendor}_long_description $page]
            if { [string length $ec_custom_fields_array(longdescription)] > 3998 } {
                ns_log Warning "ecds_import_product_from_vendor_site: ref. ${product_ref} longdescription too long, the extra clipped is: [string range $ec_custom_fields_array(longdescription) 3998 end]"
                set ec_custom_fields_array(longdescription) [string range $ec_custom_fields_array(longdescription) 0 3998]
            }

            set ec_custom_fields_array(salesdescription) [ecdsii_${vendor}_sales_description $page]
            if { [string length $ec_custom_fields_array(salesdescription)] > 3998 } {
                ns_log Warning "ecds_import_product_from_vendor_site: ref. ${product_ref} salesdescription too long, the extra clipped is: [string range $ec_custom_fields_array(salesdescription) 3998 end]"
                set ec_custom_fields_array(salesdescription) [string range $ec_custom_fields_array(salesdescription) 0 3998]
            }
            set ec_custom_fields_array(webcomments) [ecdsii_${vendor}_web_comments $page]
            if { [string length $ec_custom_fields_array(webcomments)] > 3998 } {
                ns_log Warning "ecds_import_product_from_vendor_site: ref. ${product_ref} webcomments too long, the extra clipped is: [string range $ec_custom_fields_array(webcomments) 3998 end]"
                set ec_custom_fields_array(webcomments) [string range $ec_custom_fields_array(webcomments) 0 3998]
            }

            set ec_custom_fields_array(productoptions) [ecdsii_${vendor}_product_options $page]
            if { [string length $ec_custom_fields_array(productoptions)] > 3998 } {
                ns_log Warning "ecds_import_product_from_vendor_site: ref. ${product_ref} productoptions too long, the extra clipped is: [string range $ec_custom_fields_array(productoptions) 3998 end]"
                set ec_custom_fields_array(productoptions) [string range $ec_custom_fields_array(productoptions) 0 3998]
            }
            set ec_custom_fields_array(unspsccode) [ecdsii_${vendor}_unspsc_code $page]
            if { [string length $ec_custom_fields_array(unspsccode)] > 198 } {
                ns_log Warning "ecds_import_product_from_vendor_site: ref. ${product_ref} unspsccode too long, the extra clipped is: [string range $ec_custom_fields_array(unspsccode) 198 end]"
                set ec_custom_fields_array(unspsccode) [string range $ec_custom_fields_array(unspsccode) 0 198]
            }
            set ec_custom_fields_array(vendorsku) $vendor_sku
            if { [string length $ec_custom_fields_array(vendorsku)] > 198 } {
                ns_log Warning "ecds_import_product_from_vendor_site: ref. ${product_ref} vendorsku too long, the extra clipped is: [string range $ec_custom_fields_array(vendorsku) 198 end]"
                set ec_custom_fields_array(vendorsku) [string range $ec_custom_fields_array(vendorsku) 0 198]
            }
            set ec_custom_fields_array(vendorabbrev) $vendor
            if { [string length $ec_custom_fields_array(vendorabbrev)] > 198 } {
                ns_log Warning "ecds_import_product_from_vendor_site: ref. ${product_ref} vendorabbrev too long, the extra clipped is: [string range $ec_custom_fields_array(vendorabbrev) 198 end]"
                set ec_custom_fields_array(vendorabbrev) [string range $ec_custom_fields_array(vendorabbrev) 0 198]
            }

            #ec_products fields
            set ec_products_array(sku) [ecds_sku_from_brand $ec_custom_fields_array(brandname) $ec_custom_fields_array(brandmodelnumber) $sku]
            if { [string length $ec_products_array(sku)] > 98 } {
                ns_log Warning "ecds_import_product_from_vendor_site: ref. ${product_ref} sku too long, the extra clipped is: [string range $ec_products_array(sku) 98 end]"
                set ec_products_array(sku) [string range $ec_products_array(sku) 0 98]
            }
            ns_log Notice "ecds_import_product_from_vendor_site: ref. ${product_ref} sku = $ec_products_array(sku)"
            set sku $ec_products_array(sku)

            set ec_products_array(stock_status) [ecdsii_${vendor}_stock_status $page]
            # unit_price:
            set ec_products_array(price) [ecdsii_${vendor}_unit_price $page]
            # ship weight:
            set ec_products_array(weight) [ecdsii_${vendor}_ship_weight $page]
            set ec_products_array(product_name) [ecdsii_${vendor}_product_name $page]
            if { [string length $ec_products_array(product_name)] > 198 } {
                ns_log Warning "ecds_import_product_from_vendor_site: ref. ${product_ref} product_name too long, the extra clipped is: [string range $ec_products_array(product_name) 198 end]"
                set ec_products_array(product_name) [string range $ec_products_array(product_name) 0 198]
            }

            set ec_products_array(one_line_description) [ecdsii_${vendor}_one_line_description $page]
            if { [string length $ec_products_array(one_line_description)] > 398 } {
                ns_log Warning "ecds_import_product_from_vendor_site: ref. ${product_ref} one_line_description too long, the extra clipped is: [string range $ec_products_array(one_line_description) 398 end]"
                set ec_products_array(one_line_description) [string range $ec_products_array(one_line_description) 0 398]
            }

            set ec_products_array(detailed_description) [ecdsii_${vendor}_detailed_description $page]
            if { [string length $ec_products_array(detailed_description)] > 3998 } {
                ns_log Warning "ecds_import_product_from_vendor_site: ref. ${product_ref} detailed_description too long, the extra clipped is: [string range $ec_products_array(detailed_description) 3998 end]"
                set ec_products_array(detailed_description) [string range $ec_products_array(detailed_description) 0 3998]
            }

            set original_brand_model_number [ecdsii_${vendor}_original_brand_model_number $page]
            set ec_products_array(search_keywords) "${original_brand_model_number}, $ec_products_array(one_line_description), $ec_custom_fields_array(vendorsku) $ec_custom_fields_array(brandname) $ec_custom_fields_array(brandmodelnumber)"
            if { [string length $ec_products_array(search_keywords)] > 3998 } {
                ns_log Warning "ecds_import_product_from_vendor_site: ref. ${product_ref} search_keywords too long, the extra clipped is: [string range $ec_products_array(search_keywords) 3998 end]"
                set ec_products_array(search_keywords) [string range $ec_products_array(search_keywords) 0 3998]
            }

            set ec_products_array(no_shipping_avail_p) [ecdsii_${vendor}_no_shipping_avail_p $page]
            set ec_products_array(shipping) [ecdsii_${vendor}_ec_shipping $page]
            set ec_products_array(shipping_additional) [ecdsii_${vendor}_ec_shipping_additional $page]
            # product_url:
            set ec_products_array(url) [ecdsii_${vendor}_product_url $page]
            set ec_products_array(color_list) ""
            set ec_products_array(size_list) ""
            set ec_products_array(style_list) ""
            set ec_products_array(email_on_purchase_list) [ecds_email_on_purchase_list]
            set ec_products_array(template_id) ""
            set ec_products_array(available_date) "[clock format [clock seconds] -format "%Y-%m-%d"]"
            set ec_products_array(present_p) "t"
            array set user_class_prices [list]

            # Categories may not be directly related

            set category_id_list [ecds_remove_from_list -1 [ecdsii_${vendor}_category_id_list $page]]
            set subcategory_id_list [ecds_remove_from_list -1 [ecdsii_${vendor}_subcategory_id_list $page]]
            set subsubcategory_id_list [ecds_remove_from_list -1 [ecdsii_${vendor}_subsubcategory_id_list $page]]

            # verify no serious ERRORs
            set import_conditions_met 1
            foreach attribute [list sku weight price stock_status product_name one_line_description] {
                set import_conditions_met [expr { $import_conditions_met && ![string match *ERROR* "$ec_products_array(${attribute})"] } ]
            }
            if { $import_conditions_met } {
                if { $import_mode eq "create" } {
                    #check to see if sku is already in system (we may have only checked vendor_sku before)
                    if { [db_0or1row get_product_id_if_sku_exists {select product_id from ec_products where sku =:sku } ] } {
                        # product_id found
                        set import_mode "update"
                    }
                }

                # create or update    
                if { $import_mode eq "create" } {

                    # generate a product_id
                    set product_id [db_nextval acs_object_id_seq]
                    ecds_add_product_to_ec_products $product_id ec_products_array user_class_prices $category_id_list $subcategory_id_list $subsubcategory_id_list ec_custom_fields_array
                    ns_log Notice "ecds_import_product_from_vendor_site: adding product_id $product_id"
                } else {
                    # update sql
                    # update webcomments but include old comments if there are any
                    # this gives us a web place to hold comments that do not get erased on product updates.
                    db_0or1row get_webcomments_from_product_id {select webcomments from ec_custom_product_field_values where product_id = :product_id}
                    if { [info exists webcomments] && $webcomments ne "" } {
                        set ec_custom_fields_array(webcomments) [string range "$ec_custom_fields_array(webcomments) $webcomments" 0 3998]
                        ns_log Notice "ecds_import_product_from_vendor_site: appending old webcomments to new for product_id $product_id"
                    }

                    ecds_update_ec_products_product $product_id ec_products_array user_class_prices $category_id_list $subcategory_id_list $subsubcategory_id_list ec_custom_fields_array
                    ns_log Notice "ecds_import_product_from_vendor_site: updating product_id $product_id"
                }
                # now we have a product_id

                # this requires an existing product 
                if { $image_import_location ne "ERROR" } {
                    #was ecds_import_image_to_ecommerce $product_id $image_import_location
                    if { $import_mode eq "create" } {
                        ecommerce::resource::make_product_images -product_id $product_id -tmp_filename $image_import_location -product_name $ec_products_array(product_name)
                    } else {
                        ecommerce::resource::make_product_images -product_id $product_id -tmp_filename $image_import_location
                    }
                }
                if { $import_conditions_met eq 1 } {
                    ecds_file_cache_product $product_id
                }
            }
            return $import_conditions_met  
        }
    }
} else {
    ns_log Warning "ecds_import_product_from_vendor_site: blank product_ref "
}
    # should have returned already, if everything worked
    return -1
}


ad_proc -private ecds_add_product_to_ec_products {
  product_id
  ec_products_array
  user_class_prices
  category_id_list
  subcategory_id_list
  subsubcategory_id_list
  ec_custom_fields_array
} {
  Adds product to ec_products. Requires a newly created product_id
} {
    upvar $ec_products_array ec_prods_arr $user_class_prices uclass_pri_arr $ec_custom_fields_array ec_custom_fields_arr
    ad_require_permission [ad_conn package_id] admin

    template::util::array_to_vars ec_prods_arr
    template::util::array_to_vars ec_custom_fields_arr

    # the custom product fields may or may not exist
    # and price$user_class_id for all the user classes may or may not exist
    # (because someone may have added a user class while this product was being added)

    # we need them to be logged in
    set user_id [ad_get_user_id]
    set peeraddr [ns_conn peeraddr]
    ### find out which database we are using
    # for postgresql we need to run two queries for the insert
    # for oracle, we only need to run the product_insert query
    set db_type [db_type]
    
    # make sure this product isn't already in the database (implying user reloaded page)
    if { [db_string doubleclick_select "select count(*) from ec_products where product_id=:product_id"] > 0 } {
        ad_script_abort
    }

    set user_class_id_list [db_list user_class_select "select user_class_id from ec_user_classes"]

    # grab package_id as context_id
    set context_id [ad_conn package_id]

    # let's have dirname be the first four letters (lowercase) of the product_name
    # followed by the product_id (for uniqueness)
    regsub -all {[^a-zA-Z]} $product_name "" letters_in_product_name 
    set letters_in_product_name [string tolower $letters_in_product_name]
    if [catch {set dirname "[string range $letters_in_product_name 0 3]$product_id"}] {
    #maybe there aren't 4 letters in the product name
        set dirname "$letters_in_product_name$product_id"
    }
    
    # Get the directory where dirname is stored
    set subdirectory "[ec_data_directory][ec_product_directory][ec_product_file_directory $product_id]"
    # if you get errors here
    # it may be because you have not completed your technical setup completely
    # namely you need to set 
    # the EcommerceDataDirectory parameter and ProductDataDirectory parameter
    # and create the corresponding directory in the file system
    ec_assert_directory $subdirectory
    
    set full_dirname "$subdirectory/$dirname"
    ec_assert_directory $full_dirname
    
    db_transaction {
    
      # we have to insert things into 6 tables: ec_products, ec_custom_product_field_values, 
      # ec_category_product_map, ec_subcategory_product_map, ec_subsubcategory_product_map,
      # ec_product_user_class_prices
      # and now acs_objects via the ec_product.new function
    
      # we have to generate audit information
      set audit_fields "last_modified, last_modifying_user, modified_ip_address"

      if [string match $db_type "oracle"] {
       set audit_info "sysdate, :user_id, :peeraddr"
        db_exec_plsql product_insert {
    	begin
    	:1 := ec_product.new(product_id => :product_id,
    	object_type => 'ec_product',
    	creation_date => sysdate,
    	creation_user => :user_id,
    	creation_ip => :peeraddr,
    	context_id => :context_id,
    	product_name => :product_name, 
    	price => :price, 
    	sku => :sku,
    	one_line_description => :one_line_description, 
    	detailed_description => :detailed_description, 
    	search_keywords => :search_keywords, 
    	present_p => :present_p, 
    	stock_status => :stock_status,
    	dirname => :dirname, 
    	available_date => to_date(:available_date, 'YYYY-MM-DD'), 
    	color_list => :color_list, 
    	size_list => :size_list, 
    	style_list => :style_list, 
    	email_on_purchase_list => :email_on_purchase_list, 
    	url => :url,
    	no_shipping_avail_p => :no_shipping_avail_p, 
    	shipping => :shipping,
    	shipping_additional => :shipping_additional, 
    	weight => :weight, 
    	active_p => 't',
    	template_id => :template_id
    	);
    	end;
        }
      } elseif [string match $db_type "postgresql"] {
       set audit_info "now(), :user_id, :peeraddr"
        set product_id [db_exec_plsql product_insert {
    	select ec_product__new(
            :product_id,
            :user_id,
            :context_id,
            :product_name,
            :price,
            :sku,
            :one_line_description,
            :detailed_description,
            :search_keywords,
            :present_p,
            :stock_status,
            :dirname,
            to_date(:available_date, 'YYYY-MM-DD'),
            :color_list,
            :size_list,
            :peeraddr
            );
        }]
    
        db_dml product_update {
    	update ec_products set style_list = :style_list,
            email_on_purchase_list = :email_on_purchase_list,
            url = :url,
            no_shipping_avail_p = :no_shipping_avail_p,
            shipping = :shipping,
            shipping_additional = :shipping_additional,
            weight = :weight,
            active_p = 't',
            template_id = :template_id
            where product_id = :product_id;
        }
      }
    
    
      # things to insert into ec_custom_product_field_values if they exist
      set custom_columns_to_insert [list product_id]
      set custom_column_values_to_insert [list ":product_id"]
      db_foreach custom_columns_select {
          select field_identifier
          from ec_custom_product_fields
          where active_p='t'
      } {
          if { [info exists ec_custom_fields_arr($field_identifier)] } {
              lappend custom_columns_to_insert $field_identifier
              lappend custom_column_values_to_insert ":${field_identifier}"
          }
      }
    
      db_dml custom_fields_insert "
      insert into ec_custom_product_field_values
      ([join $custom_columns_to_insert ", "], $audit_fields)
      values
      ([join $custom_column_values_to_insert ","], $audit_info)
      "
    
      # Take care of categories and subcategories and subsubcategories
      foreach category_id $category_id_list {
        db_dml category_insert "
        insert into ec_category_product_map (product_id, category_id, $audit_fields)
        values
        (:product_id, :category_id, $audit_info)
        "
      }
    
      foreach subcategory_id $subcategory_id_list {
        db_dml subcategory_insert "
        insert into ec_subcategory_product_map (
         product_id, subcategory_id, $audit_fields) values (
         :product_id, :subcategory_id, $audit_info)"
      }
    
      foreach subsubcategory_id $subsubcategory_id_list {
        db_dml subsubcategory_insert "
        insert into ec_subsubcategory_product_map (
         product_id, subsubcategory_id, $audit_fields) values (
         :product_id, :subsubcategory_id, $audit_info)"
      }
    
      # Take care of special prices for user classes
      foreach user_class_id $user_class_id_list {
        if { [info exists user_class_prices($user_class_id)] } {
          set uc_price $user_class_prices($user_class_id)
          db_dml user_class_insert "
          insert into ec_product_user_class_prices (
          product_id, user_class_id, price, $audit_fields) values (
          :product_id, :user_class_id, :uc_price, $audit_info)"
        }
      }
    }
    
}

ad_proc -private ecds_update_ec_products_product {
    product_id
    ec_products_array
    user_class_prices
    category_id_list
    subcategory_id_list
    subsubcategory_id_list
    ec_custom_fields_array
} {
    Updates a product in ec_products. Requires a product with existing product_id
} {
    upvar $ec_products_array ec_products_arr $user_class_prices user_class_pric $ec_custom_fields_array ec_custom_fields_arr
    ad_require_permission [ad_conn package_id] admin

    template::util::array_to_vars ec_products_arr
    template::util::array_to_vars ec_custom_fields_arr

    # the custom product fields may or may not exist
    # and price$user_class_id for all the user classes may or may not exist
    # (because someone may have added a user class while this product was being added)

    # we need them to be logged in
    set user_id [ad_get_user_id]
    set peeraddr [ns_conn peeraddr]

    # we have to generate audit information
    set audit_fields "last_modified, last_modifying_user, modified_ip_address"
    set audit_info "now(), :user_id, :peeraddr"
    # we have to generate audit information
    # write as update
    set audit_update "last_modified=now(), last_modifying_user=:user_id, modified_ip_address=:peeraddr"

    # make sure this product is already in the database (implying user reloaded page)
    if { [db_string doubleclick_select "select count(*) from ec_products where product_id=:product_id"] ne 1 } {
        ad_script_abort
    }

    set user_class_id_list [db_list user_class_select "select user_class_id from ec_user_classes"]

    # grab package_id as context_id
    set context_id [ad_conn package_id]

    # Get the directory where dirname is stored
    set dirname [db_string dirname_select "select dirname from ec_products where product_id=:product_id"]
    set subdirectory [ec_product_file_directory $product_id]
    set full_dirname "[ec_data_directory][ec_product_directory]$subdirectory/$dirname"
    
    db_transaction {
    
        # we have to insert or update things in 6 tables: ec_products, ec_custom_product_field_values, 
        # ec_category_product_map, ec_subcategory_product_map, ec_subsubcategory_product_map,
        # ec_product_user_class_prices
    
        db_dml product_update "
      update ec_products
      set product_name=:product_name,
          sku=:sku,
          one_line_description=:one_line_description,
          detailed_description=:detailed_description,
          color_list=:color_list,
          size_list=:size_list,
          style_list=:style_list,
          email_on_purchase_list=:email_on_purchase_list,
          search_keywords=:search_keywords,
          url=:url,
          price=:price,
          no_shipping_avail_p=:no_shipping_avail_p,
          present_p=:present_p,
          available_date=:available_date,
          shipping=:shipping,
          shipping_additional=:shipping_additional,
          weight=:weight,
          template_id=:template_id,
          stock_status=:stock_status,
          $audit_update
      where product_id=:product_id"
    
        # things to insert or update in ec_custom_product_field_values if they exist
        set custom_columns [db_list custom_columns_select "select field_identifier from ec_custom_product_fields where active_p='t'"]
        
        if { [db_string num_custom_columns "select count(*) from ec_custom_product_field_values where product_id=:product_id"] == 0 } {
            # then we want to insert, not update
            set custom_columns_to_insert [list product_id]
            set custom_column_values_to_insert [list ":product_id"]
            foreach custom_column $custom_columns {
                if { [info exists ec_custom_fields_arr($custom_column)] } {
                    lappend custom_columns_to_insert $custom_column
                    lappend custom_column_values_to_insert ":$custom_column"
                }
            }
            
            db_dml custom_field_insert "
        insert into ec_custom_product_field_values
        ([join $custom_columns_to_insert ", "], $audit_fields)
        values
        ([join $custom_column_values_to_insert ","], $audit_info)" 
        } else {
            set update_list [list]
            foreach custom_column $custom_columns {
                if { [info exists ec_custom_fields_arr($custom_column)] } {
                    lappend update_list "$custom_column=:$custom_column"
                }
            }
            
            db_dml custom_fields_update "update ec_custom_product_field_values set [join $update_list ", "], $audit_update where product_id=:product_id" 
        }
    }
        
    # Take care of categories and subcategories and subsubcategories.
    # This is going to leave current values in the map tables, remove 
    # rows no longer valid and add new rows for ids not already there.
    # Because the reference constraints go from categories to subsubcategories
    # first the subsubcategories to categories will be deleted, then
    # new categories down to subsubcategories will be added.
        
    # Make a list of categories, subcategories, subsubcategories in the database
    set old_category_id_list [db_list old_category_id_list_select "select category_id from ec_category_product_map where product_id=:product_id"]
        
    set old_subcategory_id_list [db_list old_subcategory_id_list_select "select subcategory_id from ec_subcategory_product_map where product_id=:product_id"]
        
    set old_subsubcategory_id_list [db_list old_subsubcategory_id_list_select "select subsubcategory_id from ec_subsubcategory_product_map where product_id=:product_id"]
        
    # Delete subsubcategory maps through category maps
        
    foreach old_subsubcategory_id $old_subsubcategory_id_list {
        if { [lsearch -exact $subsubcategory_id_list $old_subsubcategory_id] == -1 } {
            # This old subsubcategory id is not in the new list and needs
            # to be deleted
            db_dml subsubcategory_delete "delete from ec_subsubcategory_product_map where product_id=$product_id and subsubcategory_id=:old_subsubcategory_id"
                
            # audit
            ec_audit_delete_row [list $old_subsubcategory_id $product_id] [list subsubcategory_id product_id] ec_subsubcat_prod_map_audit
        }
    }
        
    foreach old_subcategory_id $old_subcategory_id_list {
        if { [lsearch -exact $subcategory_id_list $old_subcategory_id] == -1 } {
            # This old subcategory id is not in the new list and needs
            # to be deleted
            db_dml subcategory_delete "delete from ec_subcategory_product_map where product_id=:product_id and subcategory_id=:old_subcategory_id"
              
            # audit
            ec_audit_delete_row [list $old_subcategory_id $product_id] [list subcategory_id product_id] ec_subcat_prod_map_audit
        }
    }
        
    foreach old_category_id $old_category_id_list {
        if { [lsearch -exact $category_id_list $old_category_id] == -1 } {
            # This old category id is not in the new list and needs
            # to be deleted
            db_dml category_delete "delete from ec_category_product_map where product_id=:product_id and category_id=:old_category_id"
            
            # audit
            ec_audit_delete_row [list $old_category_id $product_id] [list category_id product_id] ec_category_product_map_audit
        }
    }
    
    # Now add categorization maps
    
    foreach new_category_id $category_id_list {
        if { [lsearch -exact $old_category_id_list $new_category_id] == -1 } {
            # The new category id is not an existing category mapping
            # so add it.
            db_dml category_insert "insert into ec_category_product_map (product_id, category_id, $audit_fields) values (:product_id, :new_category_id, $audit_info)"
        }
    }
        
    foreach new_subcategory_id $subcategory_id_list {
        if { [lsearch -exact $old_subcategory_id_list $new_subcategory_id] == -1 } {
            # The new subcategory id is not an existing subcategory mapping
            # so add it.
            db_dml subcategory_insert "insert into ec_subcategory_product_map (product_id, subcategory_id, $audit_fields) values (:product_id, :new_subcategory_id, $audit_info)"
        }
    }
        
    foreach new_subsubcategory_id $subsubcategory_id_list {
        if { [lsearch -exact $old_subsubcategory_id_list $new_subsubcategory_id] == -1 } {
            # The new subsubcategory id is not an existing subsubcategory mapping
            # so add it.
            db_dml subsubcategory_insert "insert into ec_subsubcategory_product_map (product_id, subsubcategory_id, $audit_fields) values (:product_id, :new_subsubcategory_id, $audit_info)"
        }
    }
        
    # Take care of special prices for user classes
    # First get a list of old user_class_id values and a list of all 
    # user_class_id values.
    # Then delete a user_class_price if its ID does not exist or value is empty.
    # Last go through all user_class_id values and add the user_class_price
    # if it is not in the old user_class_id_list
    set all_user_class_id_list [db_list all_user_class_id_list_select "select user_class_id from ec_user_classes"]
        
    set old_user_class_id_list [list]
    set old_user_class_price_list [list]
    db_foreach user_class_select "select user_class_id, price from ec_product_user_class_prices where product_id=:product_id" {
        lappend old_user_class_id_list $user_class_id
        lappend old_user_class_price_list $price
    }
        
    # Counter is used to find the corresponding user_class_price for the current
    # user_class_id
    set counter 0
    foreach user_class_id $old_user_class_id_list {
        if { ![info exists user_class_pric($user_class_id)] || [empty_string_p [set user_class_pric($user_class_id)]] } {
            # This old user_class_id does not have a value, so delete it
            db_dml user_class_price_delete "delete from ec_product_user_class_prices where user_class_id = :user_class_id"
            
            # audit
            ec_audit_delete_row [list $user_class_id [lindex $old_user_class_price_list $counter] $product_id] [list user_class_id price product_id] ec_product_u_c_prices_audit
        }
        incr counter
    }
        
    # Add new values
    foreach user_class_id $all_user_class_id_list {
        if { [info exists user_class_pric($user_class_id)] } {
            # This user_class_id exists and must either be inserted
            # or updated if its value has changed.
            set user_class_price $user_class_pric($user_class_id)
            
            set index [lsearch -exact $old_user_class_id_list $user_class_id]
            if { $index == -1 } {
                # This user_class_id exists and is not in the 
                db_dml user_class_price_insert "insert into ec_product_user_class_prices (product_id, user_class_id, price, $audit_fields) values (:product_id, :user_class_id, :user_class_price, $audit_info)"
            } else {
                # Check if user_class_price has changed
                if { $user_class_pric($user_class_id) != [lindex $old_user_class_price_list $index] } {
                    db_dml user_class_price_update "update ec_product_user_class_prices set price=:user_class_price, $audit_update where user_class_id = :user_class_id and product_id = :product_id"
                }
            }
        }
    }
}


ad_proc -private ecds_get_category_id_from_title {
    title 
    {context default}
} {
    returns the category_id of the referenced title, or creates a new category_id if one does not exist
} {
    db_0or1row get_normalized_title_from_alt_spelling "select normalized from ecds_alt_spelling_map where alt_spelling =:title and context=:context"
    if { ![info exists normalized]} {
        set normalized $title
    }
    db_0or1row get_category_id_from_alt_title "select category_id from ec_categories where category_name =:normalized"
    if { ![info exists category_id ] } {
        set category_id [ecds_create_ec_category $normalized]
    }
    return $category_id
}

ad_proc -private ecds_get_subcategory_id_from_title {
    title
    {context default}
    {category_id ""}
} {
    returns the subcategory_id of the referenced title (of the related category_id), or creates a new subcategory_id if one does not exist
} {
    if { [ecds_is_natural_number $category_id] } {
        db_0or1row get_normalized_title_from_alt_spelling "select normalized from ecds_alt_spelling_map where alt_spelling =:title and context=:context"
        if { ![info exists normalized] } {
            set normalized $title
        }
        db_0or1row get_subcategory_id_from_alt_title "select subcategory_id from ec_subcategories where subcategory_name =:normalized and category_id=:category_id"
        if { ![info exists subcategory_id] } {
            set subcategory_id [ecds_create_ec_subcategory $normalized $category_id]
        }
    } else {
        ns_log Warning "ecds_get_subcategory_id_from_title: unable to search for subcategory, category_id = ${category_id}"
        return -1
    }
    return $subcategory_id
}

ad_proc -private ecds_get_subsubcategory_id_from_title {
    title
    {context default}
    {category_id ""}
    {subcategory_id ""}
} {
    returns the subsubcategory_ids of the referenced title, or creates a new subsubcategory_id if one does not exist
} {
    if { [ecds_is_natural_number $category_id] && [ecds_is_natural_number $subcategory_id } {
        db_0or1row get_normalized_title_from_alt_spelling "select normalized from ecds_alt_spelling_map where alt_spelling =:title and context=:context"
        if { ![info exists normalized] } {
            set normalized $title
        }
        db_0or1row get_subsubcategory_id_from_alt_title "select subsubcategory_id from ec_subsubcategories where subsubcategory_name =:normalized and category_id=:category_id and subcategory_id = :subcategory_id"
        if { ![info exists subsubcategory_id] } {
            set subsubcategory_id [ecds_create_ec_subcategory $normalized $category_id $subcategory_id]
        }
    } else {
        ns_log Warning "ecds_get_subsubcategory_id_from_title: unable to search for subsubcategory, category_id = ${category_id}, subcategory_id = ${subcategory_id}"
        return -1
    }
    return $subsubcategory_id
}

ad_proc -private ecds_create_ec_category {
    category_name 
    {category_id ""}
    {sort_key ""}
} {
    creates a category_id with category_name
    returns category_id, or -1 if unable to insert
} {
    if { ![ecds_is_natural_number $category_id] || ![ecds_is_natural_number $sort_key] } {
        db_1row get_ec_category_id_max "select max(category_id) as max_category_id, max(sort_key) as max_sort_key from ec_categories"
        db_1row get_ec_category_sortkey_max "select max(sort_key) as min_sort_key from ec_categories where category_name < :category_name"
        db_1row get_ec_category_sortkey_min "select min(sort_key) as max_sort_key from ec_categories where category_name > :category_name"
        set category_id [db_nextval ec_category_id_sequence]
        if { ![ecds_is_natural_number $max_category_id] } {
            set max_category_id 0
        }
        if { ![info exists min_sort_key] || ![ecds_is_natural_number $min_sort_key] } {
            if { ![info exists max_sort_key] || ![ecds_is_natural_number $max_sort_key] } {
                set max_sort_key 2560
            }
            set min_sort_key [expr { int( $max_sort_key / 2. ) } ]
        }
        if { ![info exists max_sort_key] || ![ecds_is_natural_number $max_sort_key] } {
            set max_sort_key [expr { ( $min_sort_key * 2. ) + 1024. + int( rand() * 100. ) } ]
        }

        set sort_key [expr { int( ($max_sort_key + $min_sort_key ) / 2. + ( ( rand() - 0.5 )  * ( $max_sort_key - $min_sort_key ) / 2 ) )  } ]
        set category_id [ec_max [expr { $max_category_id + 1 } ] $category_id]
    }  
    # make sure values are uniqe in context of other categories
    set existing_rows_list [db_list get_category_confirmation "select category_id as cat_id from ec_categories
where category_id=:category_id or sort_key=:sort_key or category_name = :category_name"]
    if { [llength $existing_rows_list] > 0 } {
        ns_log Warning "ecds_create_ec_category: unable to create category, category_id ${category_id}, or category_name ${category_name}, or sort_key ${sort_key} not unique."
        return -1
    }

    set peeraddr [ns_conn peeraddr]
    set user_id [ad_conn user_id]
    db_dml insert_into_ec_categories "insert into ec_categories
        (category_id, category_name, sort_key, last_modified, last_modifying_user, modified_ip_address)
        values  (:category_id, :category_name, :sort_key, now(), :user_id, :peeraddr)"

    return $category_id
}

ad_proc -private ecds_create_ec_subcategory {
    subcategory_name 
    {category_id ""}
    {subcategory_id ""}
    {sort_key ""}
} {
    creates a subcategory_id with subcategory_name
    returns subcategory_id, or -1 if unable to insert
} {
    set category_id_is_nbr [ecds_is_natural_number $category_id]
    if { ![ecds_is_natural_number $subcategory_id] || !$category_id_is_valid || ![ecds_is_natural_number $sort_key] } {
        if { !$category_id_is_nbr } {
            # no valid category_id
            set category_id [ecds_get_category_id_from_title new ]
        }
        db_1row get_ec_subcategory_id_max "select max(subcategory_id) as max_subcategory_id, max(sort_key) as max_sort_key from ec_subcategories"
        db_1row get_ec_subcategory_sortkey_max "select max(sort_key) as min_sort_key from ec_subcategories where category_id =:category_id and subcategory_name < :subcategory_name"
        db_1row get_ec_subcategory_sortkey_min "select min(sort_key) as max_sort_key from ec_subcategories where category_id =:category_id and subcategory_name > :subcategory_name"
        set subcategory_id [db_nextval ec_subcategory_id_sequence]
        if { ![ecds_is_natural_number $max_subcategory_id] } {
            set max_subcategory_id 0
        }
        if { ![info exists min_sort_key] || ![ecds_is_natural_number $min_sort_key] } {
            if { ![info exists max_sort_key] || ![ecds_is_natural_number $max_sort_key] } {
                set max_sort_key 2560
            }
            set min_sort_key [expr { int( $max_sort_key / 1.89 ) } ]
        }

        if { ![info exists max_sort_key] || ![ecds_is_natural_number $max_sort_key] } {
            set max_sort_key [expr { ( $min_sort_key * 2. ) + 1024. + int( rand() * 100. ) } ]
        }

        set sort_key [expr { int( ($max_sort_key + $min_sort_key ) / 2. + ( ( rand() - 0.5 )  * ( $max_sort_key - $min_sort_key ) / 2 ) )  } ]
        set subcategory_id [ec_max [expr { $max_subcategory_id + 1 } ] $subcategory_id]
    }  
    # make sure values are uniqe in context of other categories
    set existing_rows_list [db_list get_subcategory_confirmation "select subcategory_id,subcategory_name, sort_key from ec_subcategories
where subcategory_id=:subcategory_id or ( sort_key=:sort_key and category_id = :category_id ) or subcategory_name = :subcategory_name "]
    if { [llength $existing_rows_list] > 0} {
        ns_log Warning "ecds_create_ec_subcategory: unable to create subcategory, subcategory_id ${subcategory_id}, or subcategory_name ${subcategory_name}, or sort_key ${sort_key} not unique, given max_key ${max_sort_key}, min_key ${min_sort_key} and max_subcat = ${max_subcategory_id}"
        return -1
    }

    set peeraddr [ns_conn peeraddr]
    set user_id [ad_conn user_id]
    db_dml insert_into_ec_subcategories "insert into ec_subcategories
        (subcategory_id, subcategory_name, category_id, sort_key, last_modified, last_modifying_user, modified_ip_address)
        values  (:subcategory_id, :subcategory_name, :category_id, :sort_key, now(), :user_id, :peeraddr)"

    return $subcategory_id
}

ad_proc -private ecds_create_ec_subsubcategory {
    subcategory_name 
    {category_id ""}
    {subcategory_id ""}
    {subsubcategory_id ""}
    {sort_key ""}
} {
    creates a subsubcategory_id with subsubcategory_name
    returns subsubcategory_id, or -1 if unable to insert
} {

    set category_id_is_nbr [ecds_is_natural_number $category_id]
    set subcategory_id_is_nbr [ecds_is_natural_number $subcategory_id]
    if { ![ecds_is_natural_number $subsubcategory_id] || !$subcategory_id_is_nbr || !$category_id_is_nbr || ![ecds_is_natural_number $sort_key] } {
    if { !$category_id_is_nbr } {
        # no valid category_id
        set category_id [ecds_get_category_id_from_title new ]
        set subcategory_id [ecds_get_subcategory_id_from_title new ]
    }

        set max_subsubcategory_id 0
        set min_sort_key 0
        set max_sort_key 1024
        db_1row get_ec_subsubcategory_id_max "select max(subsubcategory_id) as max_subsubcategory_id, max(sort_key) as max_sort_key from ec_subsubcategories"
        db_1row get_ec_subsubcategory_sortkey_max "select max(sort_key) as max_sort_key from ec_subsubcategories where category_id =:category_id and subsubcategory_name < :subsubcategory_name"
        db_1row get_ec_subsubcategory_sortkey_min "select min(sort_key) as min_sort_key from ec_subsubcategories where category_id =:category_id and subsubcategory_name > :subsubcategory_name"
        set subsubcategory_id [db_nextval ec_subsubcategory_id_sequence]
        set sort_key [expr { int( ($max_sort_key + $min_sort_key ) / 2 )  } ]
        set subsubcategory_id [ec_max [expr { $max_subsubcategory_id + 1} ] $subsubcategory_id]
    }  
    # make sure values are uniqe in context of other categories
    set existing_rows_list [db_list get_subsubcategory_confirmation "select subsubcategory_id,subsubcategory_name, sort_key from ec_subsubcategories
where subsubcategory_id=:subsubcategory_id or ( sort_key=:sort_key and category_id = :category_id ) or subsubcategory_name = :subsubcategory_name "]
    if { [llength $existing_rows_list] > 0} {
        ns_log Warning "ecds_create_ec_category: unable to create subsubcategory, subsubcategory_id ${subsubcategory_id}, or subsubcategory_name ${subsubcategory_name}, or sort_key ${sort_key} not unique."
        return -1
    }

    set peeraddr [ns_conn peeraddr]
    set user_id [ad_conn user_id]
    db_dml insert_into_ec_categories "insert into ec_categories
        (subsubcategory_id, subsubcategory_name, subcategory_id, category_id, sort_key, last_modified, last_modifying_user, modified_ip_address)
        values  (:subsubcategory_id, :subsubcategory_name, :subcategory_id, :category_id, :sort_key, now(), :user_id, :peeraddr)"

    return $subsubcategory_id
}

ad_proc -private ecds_vendor_choose_widget {
    {vendor_abbrev ""}
} {
    generates a choose vendor widget by vendor_title indexed by vendor_addr
} {
	set to_return "<select name=\"abbrev\"><option value=\"\">Choose vendor</option>\n"
    db_foreach get_ecds_vendors "select abbrev, title from ecds_vendors order by title" {
        if { [string equal $abbrev $vendor_abbrev] } {
            append to_return "<option value=\"${abbrev}\" selected>${title}</option>"	    
        } else {
            append to_return "<option value=\"${abbrev}\">${title}</option>"
        }
    }
	append to_return "</select>\n"
    return $to_return
}

ad_proc -private ecds_email_on_purchase_list {
} {
    returns email to notify when an order has been placed for this item.
} {
    set email [parameter::get -parameter CustomerServiceEmailAddress -default [ad_system_owner]]
    return $email
}


ad_proc -private ecds_file_cache_product {
    product_id
} {
    creates or updates a static page of product?product_id for web crawlers
} {
    set cache_product_as_file [parameter::get -parameter CacheProductAsFile -default 0]
    # Should we be creating or updating a static page for this product_id?

    # the static page for each product was $sku.html
    # for scalability, the static page for each product is now determined by ecds_product_path_from_id
    # also, note that using ${product_id}.html may not work as a default for cases without sku value, if some products have an integer sku
    set filepath_tail [ecds_product_path_from_id $product_id]
    # check if okay to start / continue this process
    if { $cache_product_as_file } {
        set cache_product_as_file [ecds_process_control_check ecds_file_cache_product okay_to_start]
    }

    if { $cache_product_as_file && [string length $filepath_tail] > 0 } {

        set ec_url_root [string trim [ec_url] /]
        set filepathname "[file join [acs_root_dir] www $ec_url_root $filepath_tail]"
        set cache_dir "[file dirname $filepathname]"
        ec_assert_directory $cache_dir
        set product_file_exists [file exists $filepathname]
        db_1row get_product_last_modification "select last_modified from ec_products where product_id = :product_id"
        if { ( $product_file_exists eq 0 ) || ( $product_file_exists && [clock scan [string range $last_modified 0 18]] > [file mtime $filepathname] ) } {
            # product file either does not exist or has been updated after the current file modification time
            # updating file

            # set use_http_get 1 = http_get, 0= ad_template::include method
            set use_http_get 1
            if { $use_http_get } {
                ns_log Notice "ecds_file_cache_product: product_id = $product_id waiting 15 seconds before trying, in case we recently ns_http ed"
                set url "[ec_insecure_location][ec_url]${filepath_tail}"
                # ec_create_new_session_if_necessary needs to NOT automatically redirect the following ns_http get 
                # to the static html file, since we want to update that file with a fresh http request
                # so, we need to remove this file before requesting it.
                if { [file exists $filepathname ] } {
                    file delete $filepathname
                }
                after 15000
                if { [catch {set get_id [ns_http queue -timeout 65 $url]} err ]} {
                    set page $err
                    ns_log Error "ecds_file_cache_product: ns_http queue url=$url error: $err"
                } else {
                    ns_log Notice "ecds_file_cache_product: ns_httping $url"
                    # removed -timeout "30" from next statment, because it is unrecognized for this instance..
                    if { [catch { ns_http wait -result page -status status $get_id } err2 ]} {
                        ns_log Error "ecds_file_cache_product: ns_http wait $err2"
                    }
                    
                    if { ![info exists status] || $status ne "200" } {
                        # no page info returned, just return error
                        if { ![info exists status] } {
                            set status "not exists"
                        }
                        set page "ecds_file_cache_product Error: url timed out with status $status"
                        ns_log Notice $page
                    } else {
                        #put page into acs_root_dir/www not packages/ecommerce/www
                        if { [catch {open $filepathname w} fileId]} {
                            ns_log Error "ecds_file_cache_product: unable to write to file $filepathname"
                            ad_script_abort
                        } else {
                            # strip extra lines and funny characters
                            regsub -all -- {[\f\e\r\v\n\t]} $page { } oneliner
                            # strip extra spaces 
                            regsub -all -- {[ ][ ]*} $oneliner { } oneliner2
                            set page $oneliner2
                            puts $fileId $page
                            ns_log Notice "ecds_file_cache_product: writing $filepathname"
                            close $fileId
                        }
                    }
                }
                
            } else {
                
                ns_log Notice "ecds_file_cache_product: product_id = $product_id"
                # create/replace product file using template::adp_include
                # 
                # ec_create_new_session_if_necessary needs to NOT automatically redirect the following ns_http get 
                # to the static html file, since we want to update that file with a fresh http request
                # so, we need to remove this file before requesting it.
                if { [file exists $filepathname ] } {
                    file delete $filepathname
                }
                set tvalue "t"
                set page [template::adp_include "/packages/ecommerce/www/product" [list product_id $product_id usca_p $tvalue ]]
                #put page into acs_root_dir/www not packages/ecommerce/www
                # maybe use: ad_return_template ?
                ns_log Notice "page = $page"
                if { [catch {open $filepathname w} fileId]} {
                    ns_log Error "ecds_file_cache_product: unable to write to file $filepathname"
                    ad_script_abort
                } else {
                    # strip extra lines and funny characters
                    regsub -all -- {[\f\e\r\v\n\t]} $page { } oneliner
                    # strip extra spaces 
                    regsub -all -- {[ ][ ]*} $oneliner { } oneliner2
                    set page $oneliner2
                    puts $fileId $page
                    ns_log Notice "ecds_file_cache_product: writing $filepathname"
                    close $fileId
                }
            }
        }
        
    } elseif { $cache_product_as_file } {
        ns_log Warning "ecds_file_cache_product: filepath is not supported for product_id $product_id"
    }
}

ad_proc -private ecds_pagination_by_items {
    item_count
    items_per_page
    first_item_displayed
} {
    returns a list of 3 pagination components, the first is a list of page_number and start_row pairs for pages before the current page, the second contains page_number and start_row for the current page, and the third is the same value pair for pages after the current page.  See ecommerce/lib/paginiation-bar for an implementation example. 
} {

    if { $items_per_page > 0 && $item_count > 0 && $first_item_displayed > 0 && $first_item_displayed <= $item_count } {
        set bar_list [list]
        set end_page [expr { ( $item_count + $items_per_page - 1 ) / $items_per_page } ]

        set current_page [expr { ( $first_item_displayed + $items_per_page - 1 ) / $items_per_page } ]

        # first row of current page \[expr { (( $current_page - 1)  * $items_per_page ) + 1 } \]

        # create bar_list with no pages beyond end_page

        if { $item_count > [expr { $items_per_page * 81 } ] } {
            # use exponential page referencing
            set relative_step 0
            set next_bar_list [list]
            set prev_bar_list [list]
            # 0.69314718056 = log(2)  
            set max_search_points [expr { int( ( log( $end_page ) / 0.69314718056 ) + 1 ) } ]
            for {set exponent 0} { $exponent <= $max_search_points } { incr exponent 1 } {
                # exponent refers to a page, relative_step refers to a relative row
                set relative_step_row [expr { int( pow( 2, $exponent ) ) } ]
                set relative_step_page $relative_step_row
                lappend next_bar_list $relative_step_page
                set prev_bar_list [linsert $prev_bar_list 0 [expr { -1 * $relative_step_page } ]]
            }

            # template_bar_list and relative_bar_list contain page numbers
            set template_bar_list [concat $prev_bar_list 0 $next_bar_list]
            set relative_bar_list [lsort -unique -increasing -integer $template_bar_list]
            
            # translalte bar_list relative values to absolute rows
            foreach {relative_page} $relative_bar_list {
                set new_page [expr { int ( $relative_page + $current_page ) } ]
                if { $new_page < $end_page } {
                    lappend bar_list $new_page 
                }
            }

        } elseif {  $item_count > [expr { $items_per_page * 10 } ] } {
            # use linear, stepped page referencing

            set next_bar_list [list 1 2 3 4 5]
            set prev_bar_list [list -5 -4 -3 -2 -1]
            set template_bar_list [concat $prev_bar_list 0 $next_bar_list]
            set relative_bar_list [lsort -unique -increasing -integer $template_bar_list]
            # translalte bar_list relative values to absolute rows
            foreach {relative_page} $relative_bar_list {
                set new_page [expr { int ( $relative_page + $current_page ) } ]
                if { $new_page < $end_page } {
                    lappend bar_list $new_page 
                }
            }
            # add absolute page references
            for {set page_number 10} { $page_number <= $end_page } { incr page_number 10 } {
                lappend bar_list $page_number
                set bar_list [linsert $bar_list 0 [expr { -1 * $page_number } ] ]
            }

        } else {
            # use complete page reference list
            for {set page_number 1} { $page_number <= $end_page } { incr page_number 1 } {
                lappend bar_list $page_number
            }
        }

        # add absolute reference for first page, last page
        lappend bar_list $end_page
        set bar_list [linsert $bar_list 0 1]

        # clean up list
        # now we need to sort and remove any remaining nonpositive integers and duplicates
        set filtered_bar_list [lsort -unique -increasing -integer [lsearch -all -glob -inline $bar_list {[0-9]*} ]]
        # delete any cases of page zero
        set zero_index [lsearch $filtered_bar_list 0]
        set bar_list [lreplace $filtered_bar_list $zero_index $zero_index]

        # generate list of lists for code in ecommerce/lib
        set prev_bar_list_pair [list]
        set current_bar_list_pair [list]
        set next_bar_list_pair [list]
        foreach page $bar_list {
            set start_item [expr { ( ( $page - 1 ) * $items_per_page ) + 1 } ]
            if { $page < $current_page } {
                lappend prev_bar_list_pair $page $start_item
            } elseif { $page eq $current_page } {
                lappend current_bar_list_pair $page $start_item
            } elseif { $page > $current_page } {
                lappend next_bar_list_pair $page $start_item
            }
        }
        set bar_list_set [list $prev_bar_list_pair $current_bar_list_pair $next_bar_list_pair]
    } else {
        ns_log Warning "ecds_pagination_by_items: parameter value(s) out of bounds for base_url $base_url $item_count $items_per_page $first_item_displayed"
    }

    return $bar_list_set
}


ad_proc -private ecds_sort_categories {
} {
    resets the order of the ec_categories table according to standard sorting of category_name text order
} {
    set category_ids_sorted_list [db_list_of_lists get_db_sorted_category_ids "
        select category_id from ec_categories order by category_name"]
    set category_count [llength $category_ids_sorted_list]
    set key_incr [expr { int( 1024. / ( $category_count + 1 ) ) + 2 } ]
    set sort_key $key_incr
    foreach category_id $category_ids_sorted_list {
        incr sort_key $key_incr
        db_dml category_sortkey_update "update ec_categories set sort_key=:sort_key where category_id =:category_id"
    }
}

ad_proc -private ecds_sort_subcategory_list {
category_id
} {
    resets the order of the ec_subcategories table for subcategories in category_id according to standard sorting of subcategory_name text order
} {
    set subcategory_ids_sorted_list [db_list_of_lists get_db_sorted_subcategory_ids "
        select subcategory_id from ec_subcategories where category_id = :category_id order by subcategory_name"]
    set subcategory_count [llength $subcategory_ids_sorted_list]
    set key_incr [expr { int( 8192. / ( $subcategory_count + 1) ) + 8 } ]
    set sort_key $key_incr
    foreach subcategory_id $subcategory_ids_sorted_list {
        incr sort_key $key_incr
        db_dml subcategory_sortkey_update "update ec_subcategories set sort_key=:sort_key where subcategory_id =:subcategory_id and category_id = :category_id"
    }
}

ad_proc -private ecds_sort_all_categories {
} {
    resets the order of the ecommerce categories according to standard sorting of category_name text order
} {
    set category_ids_sorted_list [db_list_of_lists get_db_sorted_category_ids "
        select category_id from ec_categories order by category_name"]
    set category_count [llength $category_ids_sorted_list]
    set key_incr [expr { int( 1024. / $category_count ) + 2 } ]
    set sort_key $key_incr
    foreach category_id $category_ids_sorted_list {
        incr sort_key $key_incr
        db_dml category_sortkey_update "update ec_categories set sort_key=:sort_key where category_id =:category_id"
        ecds_sort_subcategory_list $category_id
    }
}

ad_proc -private ecds_keyword_search_update {
    product_id
    {extras_list ""}
} {
    adds certain custom field values to ec_products.search_keywords, returns 1 if updated, otherwise returns 0
} {
    if { $extras_list eq "" } {
        set extras_list [list brandname brandmodelnumber unspsccode vendorsku vendorabbrev]
    }
    set success 0

    db_0or1row select_product_keywords_and_extras "select a.search_keywords, b.brandname, b.brandmodelnumber, b.unspsccode, b.vendorsku, b.vendorabbrev from ec_products a, ec_custom_product_field_values b where a.product_id = b.product_id and a.product_id = :product_id"

    # if extras are not in search_keywords, add them
    if { [info exists search_keywords ] } {
        set keywords [string tolower $search_keywords]
    } else { 
        set keywords ""
    }
    foreach extra $extras_list {
        if { ![info exists $extra] } {
            set $extra ""
            ns_log Warning "ecds_search_keywords_update: working on product_id $product_id, no info for $extra"
       } else {
            set extra_value [string tolower [expr $$extra]]
            if { [string length $extra_value] > 0 && [string first $extra_value $keywords] eq -1 } {
                set search_keywords [string range "${search_keywords}, ${extra_value}" 0 3998]
                set success 1
            }
        }
    }
    if { $success } {
        # upate search_keywords
        db_dml update_search_keywords "update ec_products set search_keywords = :search_keywords where product_id = :product_id"
    }
    return $success
}

ad_proc -private ecds_product_path_from_id {
    product_id
    {sku ""}
    {brandname ""}
    {brandmodelnumber ""}
} {
    returns the product unique portion of the local url for the product (after ec_url), either {brandname}/{brandmodelnumber}.html or {product-sku}.html or blank if not found and not enough info to create it.
} {
    # cache this query because it is used in an index.vuh that may get lots of demand
    db_0or1row -cache_key "ec-path-product-${product_id}" get_product_path_from_id "select site_url from ecds_product_id_site_url_map where product_id = :product_id"

    # if path not found, create it and store it in ecds_product_id_path_map
    if { ![info exists site_url] } {
        
        if { [string length $brandname] == 0 || [string length $brandmodelnumber] == 0 || [string length $sku] == 0 } {
            # get sku, brandname, brandmodelnumber
            db_0or1row check_product_history {select a.sku as sku,a.last_modified as last_modified, b.brandname as brandname, b.brandmodelnumber as brandmodelnumber from ec_products a, ec_custom_product_field_values b where a.product_id = b.product_id and a.product_id = :product_id }
            db_0or1row get_normalized_brand_name_from_alt_spelling "select normalized as brand_name from ecds_alt_spelling_map where alt_spelling =:brandname and context='brand'"
            if { [info exists brand_name] } {
                set brandname $brand_name
            }

        }
        if { [string length $brandmodelnumber] == 0 || [string length $sku] == 0 } {
            # we still have no prerequisites, we cannot create a file cache path
            return ""
        }
# temporary
       if { [string length $brandname] == 0 } {
            # we still have no prerequisites, we cannot create a file cache path
ns_log Warning "brandname is blank"
adp_abort
            return ""
        }

        set file_path_parts [ecds_sku_from_brand $brandname $brandmodelnumber "" "|"]
        set file_path_parts_list [split $file_path_parts "|"]
        set sku_dir [lindex $file_path_parts_list 0]
        set sku_file [lindex $file_path_parts_list 1]

        if { [string length $sku_dir] > 0 } {
            set site_url "${sku_dir}/${sku_file}"
        } else {
            set site_url $sku_file
        }

        # Verify that the site_url is not a root openacs page.
        # The cached files go into the www/ec_url dir so we do not have to worry about overwriting
        # ecommerce files, but the www/ec_url dir takes presidence in url resolving, so we still must check.
        set reserved_filename_list [list account address-2 address-international-2 address-international address billing browse-categories card-security category-browse-subcategory category-browse-subsubcategory category-browse checkout-2 checkout-3 checkout-one-form-2 checkout-one-form checkout credit-card-correction-2 credit-card-correction delete-address finalize-order gift-certificate-billing gift-certificate-claim-2 gift-certificate-claim gift-certificate-finalize-order gift-certificate-order-2 gift-certificate-order-3 gift-certificate-order-4 gift-certificate-order gift-certificate-thank-you gift-certificate index mailing-list-add-2 mailing-list-add mailing-list-remove order payment policy-privacy policy-sales-terms policy-shipping process-order-quantity-shipping process-payment product-search product review-submit-2 review-submit-3 review-submit select-shipping shopping-cart-add shopping-cart-delete-from shopping-cart-quantities-change shopping-cart-retrieve-2 shopping-cart-retrieve-3 shopping-cart-retrieve shopping-cart-save-2 shopping-cart-save shopping-cart sitemap.xml thank-you track update-user-classes-2 update-user-classes]
        if { [lsearch -exact $reserved_filename_list $site_url] >= 0 } {
            # modify site_url to be nonreserved location
            append site_url "-item"
        }
        append site_url ".html"
        # check if sku already exists elsewhere
        set dupcount 2
        while { [db_0or1row get_ecds_product_id_from_site_url "select product_id as product_id_other from ecds_product_id_site_url_map where site_url = :site_url and product_id != :product_id"] } {
            # duplicate key found! 
            ns_log Error "ecds_product_path_from_id: Duplicate key error for product_id ${product_id_other} and ${product_id} and site_url $site_url, adding suffix"
            if { $dupcount > 2 } {
                set site_url "[string range $site_url 0 end-[expr { [string length [expr { $dupcount - 1 } ]] + 5 }]]-${dupcount}.html"
            } else {
                set site_url "[string range $site_url 0 end-5]-${dupcount}.html"
            }
            incr dupcount
        }
        
            # no duplicate key, okay to add
        if { [db_0or1row get_ecds_product_id_site_url_map_for_id "select site_url as site_url_old from ecds_product_id_site_url_map where product_id = :product_id"] } {
            # map exists, update
            db_dml update_product_site_url "update ecds_product_id_site_url_map set site_url = :site_url where product_id = :product_id"
        } else {
            # new map            
            db_dml insert_product_site_url "insert into ecds_product_id_site_url_map (site_url, product_id) values (:site_url, :product_id)"
        }
    
        
    }
    return $site_url
}


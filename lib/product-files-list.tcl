# requires:  product_id

# shows a product's supporting files, blank if there are none

    set product_files_list ""
    set file_count 0
    set pretty_files ""
    set product_files ""
    set adobe_reader_blurb 0
    set dirname [db_string dirname_select "select dirname from ec_products where product_id=$product_id"]

    # make sure there are no /'s in dirname
    if { [regexp {/} $dirname] } {
        ns_log Error "ecommerce/lib/product-files-list: Invalid dirname: $dirname"
    }

    if { ![empty_string_p $dirname] } {
        set subdirectory [ec_product_file_directory $product_id]

        set full_dirname "[ec_data_directory][ec_product_directory]$subdirectory/$dirname"

        # see what's in that directory
        set file_list [glob -nocomplain -directory $full_dirname *]
  
        foreach file_name $file_list {
            set file_size [file size $file_name] 
            set file_size_kb [format "%6.1f" [expr { $file_size / 1024 }]]
            set file [lindex [file split $file_name] end]
            if { [string match {product.[jg][pi][gf]} $file] } {
                # do not show it
            } elseif { [string match {product-*.jpg} $file] } {
                # do not show it
            } else {
            append product_files "<li><a href=\"[ec_url]product-file/$subdirectory/$dirname/$file\">$file</a> (${file_size_kb}kb "
                incr file_count
                if { [string match -nocase {*.pdf} $file] } {
                     append product_files "Acrobat file"
                     set adobe_reader_blurb 1
                }

                append product_files ")</li>"
            }
        }
    }

    if { $file_count > 1 } {
        set pretty_files "s"
    }
    if { [string length ${product_files}] > 0 } {
        set product_files_list "<ul>${product_files}</ul>"
        if { $adobe_reader_blurb eq 1 } {
            append product_files_list "<p>After downloading, Acrobat (.pdf) files can 
            be viewed and printed using the free Adobe Acrobat Reader. If you do not have it, 
           <a href=\"http://www.adobe.com/prodindex/acrobat/readstep.html\" target=\"_blank\">.</p>"
        }
    }


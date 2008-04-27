ad_library {
    
    Ecommerce resource (eg. image) related procs
    
    @author Mark Aufflick (mark@aufflick.com)
    @creation-date 2008-04-26
    @cvs-id $Id$
}

namespace eval ecommerce::resource {}

ad_proc -private ecommerce::resource::make_product_images {
    -file_extension
    -product_id
    {-product_name ""}
    {-dirname ""}
    -tmp_filename
} {
    This proc creates the thumbnail and product image sized versions of an uploaded image,
    and puts them in the relevant place.

    Caller is responsible for deleting the temporary file if required (uploaded files are usually deleted
    when the thread ends).                                                                       

    Extension is currently required. Could be made optional by using 'file' to interrogate
    the image file binary.

    Product name should only be supplied for new products. For existing products to be updated,
    supply either dirname (from ec_products) or simply leave both dirname and product_name blank/missing.

    The uplodade image is currently restricted to Jpegs - TODO: resolve this

    @param -file_extension the extension of the original image file type
    @param -product_id
    @param -product_name
    @param -dirname
    @param -tmp_filename the temporary filename from your image upload etc.

    @return nothing yet

} {

    if { $file_extension ne ".jpg" } {
        ad_return_error "Bad file format" "Sorry, currently only .jpg images are supported, you uploaded a $file_extension file"
    }
    
    # get the directory name
    set resource_path [ecommerce::resource::resource_path -product_id $product_id -product_name $product_name -dirname $dirname]

    # permanent full size filename
    set perm_filename "$resource_path/product[string tolower $file_extension]"

    # copy temp file to permanent location
    ns_cp $tmp_filename $perm_filename

    # thumbnails are all jpg files
    set thumbnail [ecommerce::resource::resize_image -type Thumbnail -filename $perm_filename -dest_dir $resource_path]
    ecommerce::resource::resize_image -type ProductImage -filename $perm_filename -dest_dir $resource_path

    return $thumbnail
}

ad_proc -private ecommerce::resource::resize_image {
    -type
    -filename
    -dest_dir
} { } {
    
    # get dimensions
    set use_both_param_dimensions [parameter::get -parameter "${type}SizeOuterlimits"]
    set width_is_blank [catch {set width [parameter::get -parameter "${type}Width"]} ]
    set height_is_blank [catch {set height [parameter::get -parameter "${type}Height"]} ]
    if { $use_both_param_dimensions } {
        set convert_dimensions "${width}x${height}>"
    } else {
        if  { $width_is_blank } {
	    if  { $height_is_blank } {
	        set convert_dimensions "100x10000"
	    } else {
	        set convert_dimensions "10000x${height}"
	    }
        } else {
	    set convert_dimensions "${width}x10000"
        }
    }

    set system_url [parameter::get -package_id [ad_acs_kernel_id] -parameter SystemURL]
    set system_name [parameter::get -package_id [ad_acs_kernel_id] -parameter SystemName]
    set image_comment "from $system_url $system_name"

    set new_filename "$dest_dir/product-[string tolower $type].jpg"

    set convert [ec_convert_path]
    if {![string equal "" $convert] && [file exists $convert]} {
        if [catch {exec $convert -geometry $convert_dimensions -comment \"$image_comment\" $filename $new_filename} errmsg ] {
            ad_return_complaint 1 "
                I am sorry, an error occurred converting the picture.  $errmsg
            "
        }
    } else {
        ad_return_complaint 1 {
            I am sorry, I could not find ImageMagick's <b>convert</b> utility for
            image thumbnail creation.  Please reconfigure this subsystem before
            uploading pictures
        }
    }

    return $new_filename
}

ad_proc -private ecommerce::resource::dirname {
    -product_id
    {-product_name ""}
    {-dirname ""}
} {
    Legacy ecommerce idea of dirname, lives under the product dir and based on original product name.

    should refactor away any dealing with this directly and combine with the subdirname...

    Product name should only be supplied for new products. For existing products to be updated,
    supply either dirname (from ec_products) or simply leave both dirname and product_name blank/missing.

} {

    # if the original calling proc passed in a dirname, use that
    if {$dirname ne ""} {
        return $dirname
    }

    # If no product name, look up the dirname in the db TODO: move to xql
    if {$product_name eq ""} {
        return [db_string lookup_dirname "select dirname from ec_products where product_id = :product_id"]
    }

    # we're creating an initial dirname
    
    # let's have dirname be the first four letters (lowercase) of the product_name
    # followed by the product_id (for uniqueness)
    regsub -all {[^a-zA-Z]} $product_name "" letters_in_product_name 
    set letters_in_product_name [string tolower $letters_in_product_name]
    if [catch {set dirname "[string range $letters_in_product_name 0 3]$product_id"}] {
        #maybe there aren't 4 letters in the product name
        set dirname "$letters_in_product_name$product_id"
    }
    return $dirname
}

ad_proc -private ecommerce::resource::resource_path {
    -product_id
    {-dirname ""}
    {-product_name ""}
} {
    This proc returns the directory for images and other resources.

    Product name should only be supplied for new products. For existing products to be updated,
    supply either dirname (from ec_products) or simply leave both dirname and product_name blank/missing.


    The directory path is guaranteed to exist.

    @param -product_id
    @param -product_name
    @param -dirname

    @return disk path to product resource directory
} {
    # find the ecommerce filesystem
    set subdirectory "[ec_data_directory][ec_product_directory][ec_product_file_directory $product_id]"
    ec_assert_directory $subdirectory

    set dirname [ecommerce::resource::dirname -product_id $product_id -product_name $product_name -dirname $dirname]
    set full_dirname "$subdirectory/$dirname"
    ec_assert_directory $full_dirname

    return $full_dirname
}

ad_proc -private ecommerce::resource::resource_url {
    -product_id
    {-dirname ""}
    {-product_name ""}
} {
    This proc returns the directory for images and other resources.

    Product name should only be supplied for new products. For existing products to be updated,
    supply either dirname (from ec_products) or simply leave both dirname and product_name blank/missing.


    The directory path is guaranteed to exist.

    @param -product_id
    @param -product_name
    @param -dirname

    @return url path to product resource directory
} {
    set dirname [ecommerce::resource::dirname -product_id $product_id -product_name $product_name -dirname $dirname]
    return "[ec_url]product-file/[ec_product_file_directory $product_id]/$dirname"
}


# XXX TODO: provide memoized version

ad_proc -private ecommerce::resource::image_info {
    {-type ""}
    -product_id
    {-product_name ""}
    {-dirname ""}
} {
    Product name should only be supplied for new products. For existing products to be updated,
    supply either dirname (from ec_products) or simply leave both dirname and product_name blank/missing.

    Type is currently one of Thumbail or ProductImage (sizes as per application params) or Full or blank
    (for the original image).

    TODO: do something about alt etc.

    @param -type
    @param -product_id
    @param -product_name
    @param -dirname


    @return list (for array set) of: path, width, height or empty array if no such file
} {
    set resource_path [ecommerce::resource::resource_path -product_id $product_id -product_name $product_name -dirname $dirname]
    set resource_url [ecommerce::resource::resource_url -product_id $product_id -product_name $product_name -dirname $dirname]

    if {$type ne "" && $type ne "Full"} {
        set type "-[string tolower $type]"
    }

    set filename "product${type}.jpg"

    if { [file exists "$resource_path/$filename"] } {
        # TODO: what if full size image not jpeg?
        set thumbnail_size [ns_jpegsize "$resource_path/$filename"]

        return [list path "$resource_path/$filename" url "$resource_url/$filename" width [lindex $thumbnail_size 0] height  [lindex $thumbnail_size 1]]
    }

    ns_log Notice "unable find image info for: type: $type product_id: $product_id product_name: $product_name dirname: $dirname"
    
    return [list]
}
    

ad_proc -private ecommerce::resource::image_tag {
    {-type ""}
    -product_id
    {-product_name ""}
} {
    TODO: get product name from id if not supplied
    TODO: do something about alt etc.
} {
    set html ""

    array set info [ecommerce::resource::image_info -type $type -product_id $product_id -product_name $product_name]

    if {[lindex $info 0] ne ""} {
        set html "<img width=\"$info(width)\" height=\"$info(height)\" src=\"$info(url)\" alt=\"Product thumbnail\">"
    }

    return $html
}

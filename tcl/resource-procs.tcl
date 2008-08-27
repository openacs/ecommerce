ad_library {
    
    Ecommerce resource (eg. image) related procs
    
    @author Mark Aufflick (mark@aufflick.com)
    @creation-date 2008-04-26
    @cvs-id $Id$
}

namespace eval ecommerce::resource {}

ad_proc -private ecommerce::resource::make_product_images {
    -product_id
    -tmp_filename
    {-product_name ""}
    {-dirname ""}
} {
    This proc imports a product image and  creates the thumbnail and product image sized versions of the image.
    The original image referenced by tmp_filename is not changed.

    Product name should only be supplied when importing an image for a new product. For updating existing products,
    leave product_name blank.        

    Currently works for JPG and GIF file extensions.  PNG files are not supported by aolserver, so can be uploaded as product resources but not images.

    @param -file_extension the extension of the original image file type
    @param -product_id
    @param -product_name
    @param -dirname
    @param -tmp_filename the temporary filename from your image upload etc.

    @return dirname if worked, or 0 if there was a problem.

} {
    set success 1
    set file_extension_actual [file extension $tmp_filename]
    set file_ext_lower [string tolower $file_extension_actual]

    if { $file_ext_lower eq ".jpg" || $file_ext_lower eq ".gif" } {
 
        # get the directory name
        set resource_path [ecommerce::resource::resource_path -product_id $product_id -product_name $product_name -dirname $dirname]

        # permanent full size filename
        set perm_filename [file join $resource_path "product.${file_ext_lower}"]

        # Find and remove any previously saved product image
        # There should be no more than 1 previous file, unless another was added directly..
        set old_files_list [glob -nocomplain -- [file join $resource_path "product.\[jJgG\]\[pPiI\]\[gGfF\]"]]
        foreach old_image $old_files_list {
            if { [file exists $old_image ] } {
                file delete $old_image
            }
        }

        # copy temp file to permanent location
        # use file copy http://www.mail-archive.com/naviserver-devel@lists.sourceforge.net/msg00685.html
        if [catch {file copy $tmp_filename $perm_filename} ] {
            # when importing, there may be permissions issues
            ns_log Notice "ecommerce::resource::make_product_images: unable to copy $tmp_filename to $perm_filename"
            set success 0
        }

        # create thumbnails and standardized product image
        if { $success } {
            set success [ecommerce::resource::resize_image -type Thumbnail -filename $perm_filename -dest_dir $resource_path]
        }
        if { $success } {
            set success [ecommerce::resource::resize_image -type ProductImage -filename $perm_filename -dest_dir $resource_path]
        }
    } else {
        # flag a soft error, we do not want to ad_return_complaint because this proc may be bulk uploading product images
        set success 0
        ns_log Notice "ecommerce::resource::make_product_images: file extension ${file_extension_actuial} not supported, -product_id ${product_id}"
    }

    if { $success } {
        return $dirname
    } else {
        return 0
    }
}

ad_proc -private ecommerce::resource::resize_image {
    -type
    -filename
} { 
    Creates Thumbnail or standardized ProductImage images from a product's image based on package height and width parameters. type is Thumbnail or ProductImage. filepathname is full pathname of a product's full size image filename. Returns 0 if there is a problem, otherwise 1.
} {
    if { $type eq "Thumbnail" || $type eq "ProductImage" } {
        set success 1
        #    -dest_dir is now calculated automatically.
        set dest_dir [file dirname $filename]
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

        set new_filename [file join $dest_dir "product-[string tolower $type].jpg"]
        
        set convert [ec_convert_path]
        if { [file exists $filename] } {
            if {![string equal "" $convert] && [file exists $convert]} {
                if [catch {exec $convert -geometry $convert_dimensions -comment \"$image_comment\" $filename $new_filename} errmsg ] {
                    ns_log Notice "ecommerce::resource::resize_image An error occurred while converting a product image: $errmsg"
                    set success 0
                }
            } else {
                ad_return_complaint 1 {
                    ImageMagick's <b>convert</b> utility for
                    image thumbnail creation seems unavailable.  Please reconfigure this subsystem before
                    uploading pictures.
                }
            }
        } else {
            ns_log Notice "ecommerce::resource::resize_image product file $filename not found."
            set success 0
        }
    } else {
        set success 0
        ns_log Notice "ecommerce::resource::resize_image type unknown $type"
    }
    return $success
}

ad_proc -private ecommerce::resource::dirname {
    -product_id
    {-product_name ""}
    {-dirname ""}
} {
    Returns dirname of product with product_id

    dirname is a legacy ecommerce idea of partial product resource directory, which lives under the shared product dir and based on original product name.

    Associates a dirname with the product_id if one is not yet associated with it. Creates a new dirname if one does not exist.  product_name should be supplied for new products that have no existing dirname.  dirname is not saved for a product_id that does not exist in ec_products.

} {
    # Consider refactoring away any procedure dealing with this directly, and combine this into resource::resource_path

    # If the original calling proc passed in a dirname, consider it a suggestion if all defaults are unavailable

    # For stability, use an existing dirname if it exists in the db.
    # We do not want to have to dig around the product dir tree looking for misplaced files with generic names.
    # Existing products get a dirname when they are created.
    # This should handle all cases in most favorable way.

    # Save any previous product_name and dirname before we possibly get one from the db
    set dirname_passed $dirname
    set product_name_2 $product_name
    # the db likely caches this query, if not we should
    set product_id_exists [db_0or1row get_product_name_dirname "select dirname, product_name from ec_products where product_id = :product_id"]
    if { $product_id_exists } {
        # product_id exists
        if {$dirname ne ""} {
            # a dirname exists for product_id
            return $dirname
        } 
    }

    # Make a dirname
    # Try to use the passed dirname as a new dirname for this product_id
    set dirname $dirname_passed
    if { $dirname eq "" } {
        # dirname is blank, create a dirname from a product_name
        if { $product_name eq "" } {
            if { $product_name_passed ne "" } {
                set product_name $product_name_passed
            } else {
                # this should not happen, because product_names are required for each product
                ns_log Notice "resource::dirname no product_name available for product_id $product_id"
            }
        }
        # have dirname be the first four letters (lowercase) of the product_name
        # followed by the product_id (for uniqueness)
        regsub -all {[^a-zA-Z]} $product_name "" letters_in_product_name 
        set letters_in_product_name [string tolower $letters_in_product_name]
        if [catch {set dirname "[string range $letters_in_product_name 0 3]$product_id"}] {
            #maybe there are less than 4 letters in the product name
            set dirname "${letters_in_product_name}${product_id}"
        }
    }

    # we should associate the dirname to the product_id if we can
    if { $product_id_exists } {
        db_dml update_dirname {  update ec_products 
            set dirname = :dirname where product_id = :product_id  }
    }
    return $dirname
}

ad_proc -private ecommerce::resource::resource_path {
    -product_id
    {-dirname ""}
    {-product_name ""}
} {
    This proc returns the full directory path for a product's images and other resources. The directory is created if it does not exist.

    Product name should only be supplied for new products. For existing products to be updated,
    supply either dirname (from ec_products) or simply leave both dirname and product_name blank/missing.

    The directory path is guaranteed to exist, but be sure to save the dirname (last component)

    @param -product_id
    @param -product_name
    @param -dirname

    @return disk path to product resource directory
} {
    set dirname [ecommerce::resource::dirname -product_id $product_id -product_name $product_name -dirname $dirname]

    # find the ecommerce filesystem
    set full_dirname [file join [ec_data_directory] [ec_product_directory] [ec_product_file_directory $product_id] $dirname]

    # hmm.. if $dirname was not saved, we might be creating a rogue dir (if product_name is in flux and product_id not in db)
    # we will be ok so long as a dirname is generated whenver a new product is being created, 
    # by calling ecommerce::resource::dirname and saving the returned dirname into ec_products.
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
    set product_res_url [file join [ec_url] product-file [ec_product_file_directory $product_id] $dirname]
    return $product_res_url
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

    set dir_path [ecommerce::resource::resource_path -product_id $product_id -product_name $product_name -dirname $dirname]
    if {$type ne "" && $type ne "Full"} {
        set type "-[string tolower $type]"
        set extension ".jpg"
    } else {
        set type ""
        set full_filenames_list [glob -nocomplain -- [file join $dir_path "product.\[jJgG\]\[pPiI\]\[gGfF\]"]]
        # we assume only 1 for now, maybe we could give priority to jpg?
        set filename [lindex $full_filenames_list 0]
        set extension [string tolower [file extension $filename]]
    }

    set filename "product${type}${extension}"
    set image_pathname [file join $dir_path $filename]
    set image_url [ecommerce::resource::resource_url -product_id $product_id -product_name $product_name -dirname $dirname $filename]

    if { [file exists $image_pathname] && [file isfile $image_pathname] } {
        if { $extension eq ".jpg" } {
            set thumbnail_size [ns_jpegsize $image_pathname]
        } elseif { $extension eq ".gif" } {
            set thumbnail_size [ns_gifsize $image_pathname]
        }
        set image_info_list [list path $image_pathname url $image_url width [lindex $thumbnail_size 0] height [lindex $thumbnail_size 1]]
    } else {
        ns_log Notice "ecommerce::resource::image_info ${image_pathname} not found for type: $type product_id: $product_id product_name: $product_name dirname: $dirname"
        set image_info_list [list]
    }
    return $image_info_list
}
    

ad_proc -private ecommerce::resource::image_tag {
    {-type ""}
    -product_id
    {-product_name ""}
} {
    TODO: get product name from id if not supplied
    TODO: do something about alt etc.

} {
    # this be moved into ecommerce/lib for more templating control
    set html ""

    array set info [ecommerce::resource::image_info -type $type -product_id $product_id -product_name $product_name]

    if {[array size info] eq 3 } {
        set html "<img width=\"$info(width)\" height=\"$info(height)\" src=\"$info(url)\" alt=\"Product thumbnail\">"
    }

    return $html
}

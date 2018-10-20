ad_library {

    Customization social networking utilities

    @creation-date  Aug 2010
}

ad_proc -public ecds_share_bar {
    {url ""}
    {title ""}
} {
    returns html fragment, a series of links for sharing a webpage with others using social networking
} {
    if { $url eq "" } {
        set url [ad_return_url -qualified]
        # x and y parameters are generated in forms where submit button is type "image"
        # remove gremilin x and y parameters from form posts by GET
        # ie make urls less ugly when sharing.
        if { [ad_conn method] != "POST" } {
            regsub {[\&][x][\=][0-9]+} $url {} url
            regsub {[\&][y][\=][0-9]+} $url {} url
        }
    }
    if { $title eq "" } {
        set title [ad_conn instance_name]
        ns_log Notice "ecds_share_bar: title apparently for $url has no value, substituting with instance_name"
    }

    set url [ns_urlencode $url]
    set title [ns_urlencode $title]

    if { [security::secure_conn_p] } {
    set links_html "<span class=\"shareclass\">Share: 
<a href=\"http://twitter.com/share?url=${url}&amp;text=${title}\" target=\"_blank\" title=\"Share on Twitter\" rel=\"nofollow\">Tweet</a> 
<a href=\"http://www.facebook.com/sharer.php?u=${url}&amp;t=${title}\" target=\"_blank\" title=\"Share on Facebook\" rel=\"nofollow\">Facebook</a> 
<a href=\"http://www.stumbleupon.com/submit?url=${url}\" target=\"_blank\" title=\"Share on StumbleUpon\" rel=\"nofollow\">StumbleUpon</a> 
<a href=\"http://www.digg.com/submit?phase=2&amp;url=${url}\" target=\"_blank\" title=\"Share on Digg\" rel=\"nofollow\">Digg</a> 
<a href=\"http://del.icio.us/post?url=${url}&amp;title=${title}\" target=\"_blank\" title=\"Share on Delicious\" rel=\"nofollow\">Delicious</a>
</span>"

    } else {
    set links_html "<span class=\"shareclass\">Share: 
<a href=\"http://twitter.com/share?url=${url}&amp;text=${title}\" target=\"_blank\" title=\"Share on Twitter\" rel=\"nofollow\"><img src=\"http://twitter.com/favicon.ico\" alt=\"Tweet\" width=\"16\" height=\"16\" border=\"1\" >Tweet</a> 
<a href=\"http://www.facebook.com/sharer.php?u=${url}&amp;t=${title}\" target=\"_blank\" title=\"Share on Facebook\" rel=\"nofollow\"><img src=\"http://www.facebook.com/favicon.ico\" alt=\"Facebook\" width=\"16\" height=\"16\" border=\"1\">Facebook</a> 
<a href=\"http://www.stumbleupon.com/submit?url=${url}\" target=\"_blank\" title=\"Share on StumbleUpon\" rel=\"nofollow\"><img src=\"http://www.stumbleupon.com/favicon.ico\" alt=\"StumbleUpon\" width=\"16\" height=\"16\" border=\"1\">StumbleUpon</a> 
<a href=\"http://www.digg.com/submit?phase=2&amp;url=${url}\" target=\"_blank\" title=\"Share on Digg\" rel=\"nofollow\"><img src=\"http://cdn1.diggstatic.com/img/favicon.a015f25c.ico\" alt=\"Digg\" width=\"16\" height=\"16\" border=\"1\">Digg</a> 
<a href=\"http://del.icio.us/post?url=${url}&amp;title=${title}\" target=\"_blank\" title=\"Share on Delicious\" rel=\"nofollow\"><img src=\"http://del.icio.us/favicon.ico\" alt=\"Delicious\" width=\"16\" height=\"16\" border=\"1\">Delicious</a>
</span>"

    }
    return $links_html
}

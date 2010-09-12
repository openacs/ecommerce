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
        set url [ad_return_url]
    }
    if { $title eq "" } {
        set title [ad_conn instance_name]
        ns_log Notice "ecds_share_bar: title has no value, substituting with instance_name"
    }
    set links_html "<div class=\"shareclass\">Share: 
<a href=\"http://twitter.com/share?url=${url}&amp;text=${title}\" target=\"_blank\"><img src=\"http://twitter.com/favicon.ico\" alt=\"Tweet\">Tweet</a> 
<a href=\"http://www.facebook.com/sharer.php?u=${url}&amp;t=${title}\" target=\"_blank\" title=\"Share on Facebook\" rel=\"nofollow\"><img src=\"http://www.facebook.com/favicon.ico\" alt=\"Facebook\">Facebook</a> 
<a href=\"http://www.stumbleupon.com/submit?url=${url}\" target=\"_blank\" title=\"Share on StumbleUpon\" rel=\"nofollow\"><img src=\"http://www.stumbleupon.com/favicon.ico\" alt=\"StumbleUpon\">StumbleUpon</a> 
<a href=\"http://www.digg.com/submit?phase=2&amp;url=${url}\" target=\"_blank\" title=\"Share on Digg\" rel=\"nofollow\"><img src=\"http://www.digg.com/favicon.ico\" alt=\"Digg\">Digg</a> 
<a href=\"http://del.icio.us/post?url=${url}&amp;title=${title}\" target=\"_blank\" title=\"Share on Delicious\" rel=\"nofollow\"><img src=\"http://del.icio.us/favicon.ico\" alt=\"Delicious\">Delicious</a>
</div>"
    return $links_html
}

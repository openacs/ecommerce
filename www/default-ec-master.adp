<html>
  <head>
    <title>@title@</title>
    @header_stuff@
  </head>
  <body>
    @top_links@
    <if @navbar@ ne "none">
      <%= [ec_navbar @navbar@] %>
    </if>
    <slave>
    @footer@
    @ds_link@
  </body>
</html>

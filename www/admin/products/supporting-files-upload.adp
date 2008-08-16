<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<h3>Current Supporting Files</h3>
<ul>

<if @files_count@ eq 0>
  <p>No files found. 
    <if @dirname_exists@ false>
      @comments@
    </if>
  </p>
</if><else>
  <ul>
   @file_list_html;noquote@
  </ul>
</else>
<h3>Upload New File</h3>
<if @dirname_exists@ true>
  <blockquote>
  Note: the picture of the product is not considered a supporting file.  If you want to change it, go to
  <a href="edit?@export_product_id_html;noquote@">the regular product edit page</a>.
  <form enctype=multipart/form-data method=post action=supporting-files-upload-2>
    @export_form_product_id_html;noquote@
    <input type=file size=10 name=upload_file>
    <input type=submit value="Continue">
    </form>
 </blockquote>
</if><else>
  <p>No directory found in which to upload files.</p>
</else>

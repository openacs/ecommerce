<master>
  <property name="doc(title)">@title@</property>
  <property name="context">@context;noquote@</property>
  <property name="signatory">@ec_system_owner;noquote@</property>

  <property name="current_location">your-account</property>

<include src="/packages/ecommerce/lib/toolbar">
<include src="/packages/ecommerce/lib/searchbar">

<blockquote>
  <form method="post" action="update-user-classes-2">
    <if @user_classes_need_approval@ true>
      <p>Submit a request to be in the following user classes:</p>
    </if>
    <else>
      <p>Select the user classes you belong in:</p>
    </else>
    <blockquote>
      @user_class_select_list;noquote@
    </blockquote>
    <center>
      <input type="submit" value="Done">
    </center>
  </form>
</blockquote>

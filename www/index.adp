<master>
  <property name="title">Welcome</property>
  <property name="context_bar">@context_bar;noquote@</property>

  <include src="toolbar">

    <blockquote>
      <if @user_is_logged_on@ true>
	Welcome back @user_name@!&nbsp;&nbsp;&nbsp;If you're not @user_name@, click <a href="@register_url@">here</a>
      </if>
      <else>
	Welcome!
      </else>

      <include src="browse-categories">

      <if @recommendations_if_there_are_any@>
	<h4>We recommend:</h4>
	@recommendations_if_there_are_any@
      </if>

      <if @products@>
	<h4>Products:</h4>
	@products@
      </if>

      @prev_link@ @separator@ @next_link@
    </blockquote>

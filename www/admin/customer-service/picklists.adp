<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

<p>These items will appear in the pull-down menus for customer service data entry.
These also determine which items are singled out in reports (items not in these
lists will be grouped together under "all others").
</p>
<if @picklist_item_counter@ gt 0>
  @picklist_list_html;noquote@
</if><else>
  <p>No items have been added.  @picklist_list_html;noquote@</p>
</else>

<master>
  <property name="doc(title)">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h2>@title@</h2>

    <h3>Overview</h3>
@order_state_table_html;noquote@
      <tr>
        <td align=right><b>Order ID</td>
        <td>@order_id@</td>
        <td rowspan=4 align=right valign=top>
@order_state_gc_html;noquote@
</td>
      </tr>
      <tr>
        <td align=right><b>Ordered by</td>
        <td>@first_names@ @last_name@<br>
<if @email@ eq "no email">
@user_admin_page_html;noquote@
</if><else>
@email@
</else>
</td>
      </tr>
      <tr>
        <td align=right><b>Confirmed date</td>
        <td>@confirmed_date_html;noquote@</td>
      </tr>
      <tr>
        <td align=right><b>Order state</td>
        <td>@order_state_void_html;noquote@</td>
      </tr>
    </table>
<if @order_state@ eq "void">
	<h3>Details of Void</h3>
	<blockquote>
	  Voided by: @details_of_void_html;noquote@
	</blockquote>
</if>
@comments_html;noquote@

<h3>Items</h3>
    <ul>
@items_ul;noquote@
    </ul>
<h3>Details</h3>
    <table>
      <tr>
@order_details_html;noquote@
    </table>
<h3>Financial Transactions</h3>
@financial_transaction_html;noquote@

<h3>Shipments</h3>
    <blockquote>
@shipments_html;noquote@
    </blockquote>

<h3>Returns</h3>
    <blockquote>
@refunds_html;noquote@
    </blockquote>

<if @order_state@ ne "void">
<h3>Actions</h3>
	<ul>
@actions_html;noquote@
</ul>
</if>

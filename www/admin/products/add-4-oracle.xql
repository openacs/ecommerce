<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="product_insert">      
      <querytext>
      
	begin
	:1 := ec_product.new(product_id => :product_id,
	object_type => 'ec_product',
	creation_date => sysdate,
	creation_user => :user_id,
	creation_ip => :peeraddr,
	context_id => :context_id,
	product_name => :product_name, 
	price => :price, 
	sku => :sku,
	one_line_description => :one_line_description, 
	detailed_description => :detailed_description, 
	search_keywords => :search_keywords, 
	present_p => :present_p, 
	stock_status => :stock_status,
	dirname => :dirname, 
	available_date => to_date(:available_date, 'YYYY-MM-DD'), 
	color_list => :color_list, 
	size_list => :size_list, 
	style_list => :style_list, 
	email_on_purchase_list => :email_on_purchase_list, 
	url => :url,
	no_shipping_avail_p => :no_shipping_avail_p, 
	shipping => :shipping,
	shipping_additional => :shipping_additional, 
	weight => :weight, 
	active_p => 't',
	template_id => :template_id
	);
	end;
    
      </querytext>
</fullquery>


<fullquery name="audit_info_sql">
      <querytext>

      sysdate, :user_id, :peeraddr

      </querytext>
</fullquery>
 
</queryset>

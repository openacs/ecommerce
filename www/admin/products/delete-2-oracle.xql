<?xml version="1.0"?>

<queryset>
   <rdbms><type>oracle</type><version>8.1.6</version></rdbms>

<fullquery name="product_delete">      
      <querytext>
      
      begin
      ec_product.delete(:product_id);
      end;
  
      </querytext>
</fullquery>

 
</queryset>

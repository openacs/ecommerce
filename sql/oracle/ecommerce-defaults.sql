--
-- ecommerce-defaults.sql
--
-- by eveander@arsdigita.com, April 1999
-- and ported by Jerry Asher (jerry@theashergroup.com)
-- and Walter McGinnis (wtem@olywa.net)
--
-- 03-11-2001
-- 
-- derived from ecommerce.sql (renamed ecommerce-create.sql in 4.x port)
/*
 * you have just started to load ecommerce-defaults.sql
 * this file should be loaded after an administrator 
 * has been created for the ACS installation
 * if you get errors loading this page during ACS installation, 
 * finish the installation and then load it manually with sqlplus 
 * with the following command from within 
 * the /web/service_name/packages/ecommerce/sql directory:
 *
 * sqlplus service_name/database_password < ecommerce-defaults.sql
 *
 */

-- This inserts the default template into the ec_templates table
insert into ec_templates (
        template_id, template_name, template,
        last_modified, last_modifying_user, modified_ip_address
        ) values (
        1,'Default',
        '<head>' || CHR(10) || '<title><%= $product_name %></title>' || CHR(10) || '</head>' || CHR(10)
        || '<body bgcolor=white text=black>' || CHR(10) || CHR(10)
        || '<ec_navbar>$category_id</ec_navbar>' || CHR(10)
        || '<h2><%= $product_name %></h2>' || CHR(10)  || CHR(10)
        || '<table width=100%>' || CHR(10)
        || '<tr>' || CHR(10)
        || '<td>' || CHR(10)
        || ' <table>' || CHR(10)
        || ' <tr>' || CHR(10)
        || ' <td><%= [ec_linked_thumbnail_if_it_exists $dirname] %></td>' || CHR(10)
        || ' <td>' || CHR(10)
        ||     ' <b><%= $one_line_description %></b>' || CHR(10)
        ||     ' <br>' || CHR(10)
        ||     ' <%= [ec_price_line $product_id $user_id $offer_code] %>' || CHR(10)
        || ' </td>' || CHR(10)
        || ' </tr>' || CHR(10)
        || ' </table>' || CHR(10)
        || '</td>' || CHR(10)
        || '<td align=center>' || CHR(10) || '<%= [ec_add_to_cart_link $product_id] %>' || CHR(10) || '</td>' || CHR(10)
        || '</tr>' || CHR(10)
        || '</table>' || CHR(10) || CHR(10)
        || '<p>' || CHR(10)
        || '<%= $detailed_description %>' || CHR(10) || CHR(10)
        || '<%= [ec_display_product_purchase_combinations $product_id] %>' || CHR(10) || CHR(10)
        || '<%= [ec_product_links_if_they_exist $product_id] %>' || CHR(10) || CHR(10)
        || '<%= [ec_professional_reviews_if_they_exist $product_id] %>' || CHR(10) || CHR(10)
        || '<%= [ec_customer_comments $product_id $comments_sort_by] %>' || CHR(10) || CHR(10)
        || '<p>' || CHR(10) || CHR(10)
        || '<%= [ec_mailing_list_link_for_a_product $product_id] %>' || CHR(10) || CHR(10)
        || '<%= [ec_footer] %>' || CHR(10)
        || '</body>' || CHR(10)
        || '</html>',
        sysdate, (select grantee_id
                    from acs_permissions
                   where object_id = acs.magic_object_id('security_context_root')
                     and privilege = 'admin'
                     and rownum = 1),
        'none');



-- put one row into ec_admin_settings so that I don't have to use 0or1row
insert into ec_admin_settings (
        admin_setting_id,
        default_template,
        last_modified,
        last_modifying_user,
        modified_ip_address
        ) values (
        1,
        1,
        sysdate, (select grantee_id
                    from acs_permissions
                   where object_id = acs.magic_object_id('security_context_root')
                     and privilege = 'admin'
                     and rownum = 1),
        'none');


-- The following templates are predefined ecommerce-defaults.
-- The templates are
-- used in procedures which send out the email, so the template_ids
-- shouldn't be changed, although the text can be edited at
-- [ec_url_concat [ec_url] /admin]/email-templates/
--
-- email_template_id    used for
-- -----------------    ---------
--      1               new order
--      2               order shipped
--      3               delayed credit denied
--      4               new gift certificate order
--      5               gift certificate recipient
--      6               gift certificate order failure

set scan off

insert into ec_email_templates
(email_template_id, title, subject, message, variables, when_sent, issue_type_list, last_modified, last_modifying_user, modified_ip_address)
values
(1, 'New Order', 'Your Order',
'Thank you for your order.  We received your order' || CHR(10)
|| 'on confirmed_date_here.' || CHR(10) || CHR(10)
|| 'The following is your order information:' || CHR(10) || CHR(10)
|| 'item_summary_here' || CHR(10) || CHR(10)
|| 'Shipping Address:' || CHR(10)
|| 'address_here' || CHR(10) || CHR(10)
|| 'price_summary_here' || CHR(10) || CHR(10)
|| 'Thank you.' || CHR(10) || CHR(10) 
|| 'Sincerely,' || CHR(10) 
|| 'customer_service_signature_here',
'confirmed_date_here, address_here, item_summary_here, price_here, shipping_here, tax_here, total_here, customer_service_signature_here',
'This email will automatically be sent out after an order has been authorized.',
'{new order}',
sysdate,
                 (select grantee_id
                    from acs_permissions
                   where object_id = acs.magic_object_id('security_context_root')
                     and privilege = 'admin'
                     and rownum = 1), 'none');

insert into ec_email_templates
(email_template_id, title, subject, message, variables, when_sent, issue_type_list, last_modified, last_modifying_user, modified_ip_address)
values
(2, 'Order Shipped', 'Your Order Has Shipped',
'We shipped the following items on shipped_date_here:' || CHR(10) || CHR(10) 
|| 'item_summary_here' || CHR(10) || CHR(10) 
|| 'Your items were shipped to:' || CHR(10) || CHR(10) 
|| 'address_here' || CHR(10) || CHR(10) 
|| 'sentence_about_whether_this_completes_the_order_here' || CHR(10) || CHR(10) 
|| 'You can track your package by accessing' || CHR(10) 
|| '"Your Account" at system_url_here' || CHR(10) || CHR(10) 
|| 'Sincerely,' || CHR(10) 
|| 'customer_service_signature_here',
'shipped_date_here, item_summary_here, address_here, sentence_about_whether_this_completes_the_order_here, system_url_here, customer_service_signature_here',
'This email will automatically be sent out after an order or partial order has shipped.',
'{order shipped}',
sysdate,
(select grantee_id
                    from acs_permissions
                   where object_id = acs.magic_object_id('security_context_root')
                     and privilege = 'admin'
                     and rownum = 1),
'none');


insert into ec_email_templates
(email_template_id, title, subject, message, variables, when_sent, issue_type_list, last_modified, last_modifying_user, modified_ip_address)
values
(3, 'Delayed Credit Denied', 'Your Order',
'At this time we are not able to receive' || CHR(10) 
|| 'authorization to charge your account.  We' || CHR(10) 
|| 'have saved your order so that you can come' || CHR(10) 
|| 'back to system_url_here' || CHR(10) 
|| 'and resubmit it.' || CHR(10) || CHR(10) 
|| 'Please go to your shopping cart and' || CHR(10) 
|| 'click on "Retrieve Saved Cart".' || CHR(10) || CHR(10) 
|| 'Thank you.' || CHR(10) || CHR(10) 
|| 'Sincerely,' || CHR(10) 
|| 'customer_service_signature_here',
'system_url_here, customer_service_signature_here',
'This email will automatically be sent out after a credit card authorization fails if it didn''t fail at the time the user initially submitted their order.',
'billing',
sysdate,
(select grantee_id
                    from acs_permissions
                   where object_id = acs.magic_object_id('security_context_root')
                     and privilege = 'admin'
                     and rownum = 1),
'none');


insert into ec_email_templates
(email_template_id, title, subject, message, variables, when_sent, issue_type_list, last_modified, last_modifying_user, modified_ip_address)
values
(4, 'New Gift Certificate Order', 'Your Order',
'Thank you for your gift certificate order at system_name_here!' || CHR(10) || CHR(10) 
|| 'The gift certificate will be sent to:' || CHR(10) || CHR(10) 
|| 'recipient_email_here' || CHR(10) || CHR(10) 
|| 'Your order details:' || CHR(10) || CHR(10) 
|| 'Gift Certificate   certificate_amount_here' || CHR(10) 
|| 'Shipping           0.00' || CHR(10) 
|| 'Tax                0.00' || CHR(10) 
|| '------------       ------------' || CHR(10) 
|| 'TOTAL              certificate_amount_here' || CHR(10) || CHR(10) 
|| 'Sincerely,' || CHR(10) 
|| 'customer_service_signature_here',
'system_name_here, recipient_email_here, certificate_amount_here, customer_service_signature_here',
'This email will be sent after a customer orders a gift certificate.',
'{gift certificate}',
sysdate,
(select grantee_id
                    from acs_permissions
                   where object_id = acs.magic_object_id('security_context_root')
                     and privilege = 'admin'
                     and rownum = 1),
'none');


insert into ec_email_templates
(email_template_id, title, subject, message, variables, when_sent, issue_type_list, last_modified, last_modifying_user, modified_ip_address)
values
(5, 'Gift Certificate Recipient', 'Gift Certificate',
'It''s our pleasure to inform you that someone' || CHR(10) 
|| 'has purchased a gift certificate for you at' || CHR(10) 
|| 'system_name_here!' || CHR(10) || CHR(10) 
|| 'Use the claim check below to retrieve your gift' || CHR(10) 
|| 'certificate at system_url_here' || CHR(10) || CHR(10) 
|| 'amount_and_message_summary_here' || CHR(10) || CHR(10) 
|| 'Claim Check: claim_check_here' || CHR(10) || CHR(10) 
|| 'To redeem it, just go to' || CHR(10) 
|| 'system_url_here' || CHR(10) 
|| 'choose the items you wish to purchase,' || CHR(10) 
|| 'and proceed to Checkout.  You''ll then have' || CHR(10) 
|| 'the opportunity to type in your claim code' || CHR(10) 
|| 'and redeem your certificate!  Any remaining' || CHR(10) 
|| 'balance must be paid for by credit card.' || CHR(10) || CHR(10) 
|| 'Sincerely,' || CHR(10) 
|| 'customer_service_signature_here',
'system_name_here, system_url_here, amount_and_message_summary_here, claim_check_here, customer_service_signature_here',
'This is sent to recipients of gift certificates.',
'{gift certificate}',
sysdate,
(select grantee_id
                    from acs_permissions
                   where object_id = acs.magic_object_id('security_context_root')
                     and privilege = 'admin'
                     and rownum = 1),
'none');

insert into ec_email_templates
(email_template_id, title, subject, message, variables, when_sent, issue_type_list, last_modified, last_modifying_user,  modified_ip_address)
values
(6, 'Gift Certificate Order Failure', 'Your Gift Certificate Order',
'We are sorry to report that the authorization' || CHR(10) 
|| 'for the gift certificate order you placed' || CHR(10) 
|| 'at system_name_here could not be made.' || CHR(10) 
|| 'Your order has been canceled.  Please' || CHR(10) 
|| 'come back and try your order again at:' || CHR(10) || CHR(10) 
|| 'system_url_here' || CHR(10) 
|| 'For your records, here is the order' || CHR(10) 
|| 'that you attempted to place:' || CHR(10) || CHR(10) 
|| 'Would have been sent to: recipient_email_here' || CHR(10) 
|| 'amount_and_message_summary_here' || CHR(10) 
|| 'We apologize for the inconvenience.' || CHR(10) 
|| 'Sincerely,' || CHR(10) 
|| 'customer_service_signature_here',
'system_name_here, system_url_here, recipient_email_here, amount_and_message_summary_here, customer_service_signature_here',
'This is sent to customers who tried to purchase a gift certificate but got no immediate response from CyberCash and we found out later the auth failed.',
'{gift certificate}', sysdate,
                 (select grantee_id
                    from acs_permissions
                   where object_id = acs.magic_object_id('security_context_root')
                     and privilege = 'admin'
                     and rownum = 1),
'none');

set scan on

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
        '<head>' || '\n' || '<title><%= $product_name %></title>' || '\n' || '</head>' || '\n'
        || '<body bgcolor=white text=black>' || '\n' || '\n'
        || '<ec_navbar>$category_id</ec_navbar>' || '\n'
        || '<h2><%= $product_name %></h2>' || '\n'  || '\n'
        || '<table width=100%>' || '\n'
        || '<tr>' || '\n'
        || '<td>' || '\n'
        || ' <table>' || '\n'
        || ' <tr>' || '\n'
        || ' <td><%= [ec_linked_thumbnail_if_it_exists $dirname] %></td>' || '\n'
        || ' <td>' || '\n'
        ||     ' <b><%= $one_line_description %></b>' || '\n'
        ||     ' <br>' || '\n'
        ||     ' <%= [ec_price_line $product_id $user_id $offer_code] %>' || '\n'
        || ' </td>' || '\n'
        || ' </tr>' || '\n'
        || ' </table>' || '\n'
        || '</td>' || '\n'
        || '<td align=center>' || '\n' || '<%= [ec_add_to_cart_link $product_id] %>' || '\n' || '</td>' || '\n'
        || '</tr>' || '\n'
        || '</table>' || '\n' || '\n'
        || '<p>' || '\n'
        || '<%= $detailed_description %>' || '\n' || '\n'
        || '<%= [ec_display_product_purchase_combinations $product_id] %>' || '\n' || '\n'
        || '<%= [ec_product_links_if_they_exist $product_id] %>' || '\n' || '\n'
        || '<%= [ec_professional_reviews_if_they_exist $product_id] %>' || '\n' || '\n'
        || '<%= [ec_customer_comments $product_id $comments_sort_by] %>' || '\n' || '\n'
        || '<p>' || '\n' || '\n'
        || '<%= [ec_mailing_list_link_for_a_product $product_id] %>' || '\n' || '\n'
        || '<%= [ec_footer] %>' || '\n'
        || '</body>' || '\n'
        || '</html>',
        now(), (select grantee_id
                    from acs_permissions
                   where object_id = acs__magic_object_id('security_context_root')
                     and privilege = 'admin'
                     limit 1),
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
        now(), (select grantee_id
                    from acs_permissions
                   where object_id = acs__magic_object_id('security_context_root')
                     and privilege = 'admin'
                     limit 1),
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

-- set scan off

insert into ec_email_templates
(email_template_id, title, subject, message, variables, when_sent, issue_type_list, last_modified, last_modifying_user, modified_ip_address)
values
(1, 'New Order', 'Your Order',
'Thank you for your order.  We received your order' || '\n'
|| 'on confirmed_date_here.' || '\n' || '\n'
|| 'The following is your order information:' || '\n' || '\n'
|| 'item_summary_here' || '\n' || '\n'
|| 'Shipping Address:' || '\n'
|| 'address_here' || '\n' || '\n'
|| 'price_summary_here' || '\n' || '\n'
|| 'Thank you.' || '\n' || '\n' 
|| 'Sincerely,' || '\n' 
|| 'customer_service_signature_here',
'confirmed_date_here, address_here, item_summary_here, price_here, shipping_here, tax_here, total_here, customer_service_signature_here',
'This email will automatically be sent out after an order has been authorized.',
'{new order}',
now(),
                 (select grantee_id
                    from acs_permissions
                   where object_id = acs__magic_object_id('security_context_root')
                     and privilege = 'admin'
                     limit 1), 'none');

insert into ec_email_templates
(email_template_id, title, subject, message, variables, when_sent, issue_type_list, last_modified, last_modifying_user, modified_ip_address)
values
(2, 'Order Shipped', 'Your Order Has Shipped',
'We shipped the following items on shipped_date_here:' || '\n' || '\n' 
|| 'item_summary_here' || '\n' || '\n' 
|| 'Your items were shipped to:' || '\n' || '\n' 
|| 'address_here' || '\n' || '\n' 
|| 'sentence_about_whether_this_completes_the_order_here' || '\n' || '\n' 
|| 'You can track your package by accessing' || '\n' 
|| '"Your Account" at system_url_here' || '\n' || '\n' 
|| 'Sincerely,' || '\n' 
|| 'customer_service_signature_here',
'shipped_date_here, item_summary_here, address_here, sentence_about_whether_this_completes_the_order_here, system_url_here, customer_service_signature_here',
'This email will automatically be sent out after an order or partial order has shipped.',
'{order shipped}',
now(),
(select grantee_id
                    from acs_permissions
                   where object_id = acs__magic_object_id('security_context_root')
                     and privilege = 'admin'
                     limit 1),
'none');


insert into ec_email_templates
(email_template_id, title, subject, message, variables, when_sent, issue_type_list, last_modified, last_modifying_user, modified_ip_address)
values
(3, 'Delayed Credit Denied', 'Your Order',
'At this time we are not able to receive' || '\n' 
|| 'authorization to charge your account.  We' || '\n' 
|| 'have saved your order so that you can come' || '\n' 
|| 'back to system_url_here' || '\n' 
|| 'and resubmit it.' || '\n' || '\n' 
|| 'Please go to your shopping cart and' || '\n' 
|| 'click on "Retrieve Saved Cart".' || '\n' || '\n' 
|| 'Thank you.' || '\n' || '\n' 
|| 'Sincerely,' || '\n' 
|| 'customer_service_signature_here',
'system_url_here, customer_service_signature_here',
'This email will automatically be sent out after a credit card authorization fails if it didn''t fail at the time the user initially submitted their order.',
'billing',
now(),
(select grantee_id
                    from acs_permissions
                   where object_id = acs__magic_object_id('security_context_root')
                     and privilege = 'admin'
                     limit 1),
'none');


insert into ec_email_templates
(email_template_id, title, subject, message, variables, when_sent, issue_type_list, last_modified, last_modifying_user, modified_ip_address)
values
(4, 'New Gift Certificate Order', 'Your Order',
'Thank you for your gift certificate order at system_name_here!' || '\n' || '\n' 
|| 'The gift certificate will be sent to:' || '\n' || '\n' 
|| 'recipient_email_here' || '\n' || '\n' 
|| 'Your order details:' || '\n' || '\n' 
|| 'Gift Certificate   certificate_amount_here' || '\n' 
|| 'Shipping           0.00' || '\n' 
|| 'Tax                0.00' || '\n' 
|| '------------       ------------' || '\n' 
|| 'TOTAL              certificate_amount_here' || '\n' || '\n' 
|| 'Sincerely,' || '\n' 
|| 'customer_service_signature_here',
'system_name_here, recipient_email_here, certificate_amount_here, customer_service_signature_here',
'This email will be sent after a customer orders a gift certificate.',
'{gift certificate}',
now(),
(select grantee_id
                    from acs_permissions
                   where object_id = acs__magic_object_id('security_context_root')
                     and privilege = 'admin'
                     limit 1),
'none');


insert into ec_email_templates
(email_template_id, title, subject, message, variables, when_sent, issue_type_list, last_modified, last_modifying_user, modified_ip_address)
values
(5, 'Gift Certificate Recipient', 'Gift Certificate',
'It''s our pleasure to inform you that someone' || '\n' 
|| 'has purchased a gift certificate for you at' || '\n' 
|| 'system_name_here!' || '\n' || '\n' 
|| 'Use the claim check below to retrieve your gift' || '\n' 
|| 'certificate at system_url_here' || '\n' || '\n' 
|| 'amount_and_message_summary_here' || '\n' || '\n' 
|| 'Claim Check: claim_check_here' || '\n' || '\n' 
|| 'To redeem it, just go to' || '\n' 
|| 'system_url_here' || '\n' 
|| 'choose the items you wish to purchase,' || '\n' 
|| 'and proceed to Checkout.  You''ll then have' || '\n' 
|| 'the opportunity to type in your claim code' || '\n' 
|| 'and redeem your certificate!  Any remaining' || '\n' 
|| 'balance must be paid for by credit card.' || '\n' || '\n' 
|| 'Sincerely,' || '\n' 
|| 'customer_service_signature_here',
'system_name_here, system_url_here, amount_and_message_summary_here, claim_check_here, customer_service_signature_here',
'This is sent to recipients of gift certificates.',
'{gift certificate}',
now(),
(select grantee_id
                    from acs_permissions
                   where object_id = acs__magic_object_id('security_context_root')
                     and privilege = 'admin'
                     limit 1),
'none');

insert into ec_email_templates
(email_template_id, title, subject, message, variables, when_sent, issue_type_list, last_modified, last_modifying_user,  modified_ip_address)
values
(6, 'Gift Certificate Order Failure', 'Your Gift Certificate Order',
'We are sorry to report that the authorization' || '\n' 
|| 'for the gift certificate order you placed' || '\n' 
|| 'at system_name_here could not be made.' || '\n' 
|| 'Your order has been canceled.  Please' || '\n' 
|| 'come back and try your order again at:' || '\n' || '\n' 
|| 'system_url_here' || '\n' 
|| 'For your records, here is the order' || '\n' 
|| 'that you attempted to place:' || '\n' || '\n' 
|| 'Would have been sent to: recipient_email_here' || '\n' 
|| 'amount_and_message_summary_here' || '\n' 
|| 'We apologize for the inconvenience.' || '\n' 
|| 'Sincerely,' || '\n' 
|| 'customer_service_signature_here',
'system_name_here, system_url_here, recipient_email_here, amount_and_message_summary_here, customer_service_signature_here',
'This is sent to customers who tried to purchase a gift certificate but got no immediate response from CyberCash and we found out later the auth failed.',
'{gift certificate}', now(),
                 (select grantee_id
                    from acs_permissions
                   where object_id = acs__magic_object_id('security_context_root')
                     and privilege = 'admin'
                     limit 1),
'none');

-- set scan on

<master src=master>
<property name=title>Setup of the Ecommerce Module</property>

<!-- wtem@olywa.net -- 03-10-2001 -- a navbar here would be nice, should be able to handle it in the master template with a  property passed in -->

This is intended to be a guide for the content administrators of the site.
Content administrators are not assumed to have any technical expertise
(although HTML knowledge is necessary if you want to edit product templates).
<p>
These are the basic steps needed to get your ecommerce system up and running.
Most functions below can be performed using the
ecommerce administration pages in
<a href="@ec_url@admin/">@ec_url@admin/</a> (must be accessed using HTTPS).

<ol>
<li>First make sure that the <a href="ecommerce-technical">technical setup</a>
has been taken care of.  Although most of it can be done quickly, the 
process of setting up a merchant account to accept credit cards can take weeks,
so don't procrastinate!
<p>
You will need to answer the following questions for whomever will be
administring the ecommerce site parameters, and for those individuals adding products or services to your site.
<p>
If you don't know what some of these
questions mean, read on.  These should make sense after you've finished
reading this page.
<p>
<ol type=A>

<li>what units of currency and weight (e.g. USD and lbs) will be used
throughout the site

<li>whether you are selling products or services (items that are not
shipped)

<li>how many products to display per page when the customer is
browsing (default 10)

<li>whether to allow users to write public comments of the products
and, if so, whether the comments need to be approved (by you) before
they appear on the site

<li>whether you want product relationships (e.g. "people who bought
product A also bought products B, C, and D") to be calculated and
displayed


<li>regarding user classes (i.e., classes that you might place users
in like "publisher" or "student" for purposes of giving discounts or
different views of the site): (a) do you want them to know what
classes they're in? (b) can they request via the web site to be placed
into user classes, and (c) if so, do they automatically become a
member of any user class they request to be a part of, or do their
requests need to be approved by an administrator first?

<li>what percentage of the shipping charges should be refunded if a
customer returns their purchases

<li>whether express shipping is available

<li>whether you want to save credit card data (if so, customers can
reuse their credit card with one click; if not, the credit card number
is deleted after the order has shipped)

<li>how large you want the automatically-generated thumbnail images of
the products to be (you can specify either the width or the height, in
pixels; the dimension you don't specify will vary based on the
original image's size)

<li>what product stock messages you want to be able to choose from
when adding/editing products (e.g. "Out of Stock", "Usually Ships
Within 24 Hours", "Usually Ships Within 2-3 Days", etc.)

<li>the number of days a user's shopping cart will stay valid before
it goes into the 'expired' state

<li>whether to allow preorders for items that are not yet available

<li>the email address that will be used for all email sent from the
system to the customers

<li>whether people fulfilling the orders should be alerted if there's
a problem reauthorizing a credit card for payment (which happens when
orders are shipped) -- you'll want them to be alerted if they're in a
position to do anything about the problem (e.g. abort the shipment);
otherwise, there's no need to alert them because the problem will
still be logged so that someone else can take care of it

<li>whether customers are allowed to purchase gift certificates for
others and, if so, the minimum and maximum amounts of money that the
gift certificates can be worth as well as the number of months until
the gift certificates expire

</ol>

<p> <li>Set up product categorization (<a href="@ec_url@admin/cat/">@ec_url@admin/cat/</a>):

<p>

Product categories, subcategories and subsubcategories are optional,
but if you intend to offer many products for sale, it is best to think
about how they should be categorized <i>before</i> you enter any products into
the database.  The categorization is used when displaying the products and when the
customer is searching for products.

<p>

Here is an example to help you decide how you want to categorize your
products.  Say you are a publisher and you are selling a variety of
books and periodicals.  You may wish to divide your goods into
two categories: books and periodicals.  The subcategories of books
will be: fiction, biography, history, science, and so on.  The
subcategories of periodicals will be: health &amp; fitness, sports,
news, beauty, and so on.  If you want to go a level deeper, you
can subdivide science, for instance, into physics, chemistry, biology,
geology, and so on.

<p>

Another example: say you sell CDs and nothing else.  Then your
categories can be: classical, rock, jazz, international, etc.
You will probably not need to use subcategories.

<p>

What if one of your products spans two categories?  That's OK; you are allowed
to put a product into as many categories (and subcategories and subsubcategories)
as you like.  So, if you're
selling the <i>Girl From Ipanema</i> CD, you can put it into both
the jazz and the international categories so that your customers
can find it in both places.

<p>

<li>Set up your shipping cost rules (<a href="@ec_url@admin/shipping-costs/">@ec_url@admin/shipping-costs/</a>).
The ecommerce module is flexible regarding how you charge your
customers for shipping.  The <a href="@ec_url@admin/shipping-costs/"
>Shipping Costs page</a> in the admin section
will lead you through it.  Make sure you read the <a href="@ec_url@admin/shipping-costs/examples">Shipping Cost Examples
page</a> if you don't already know how you want to set it up.

<p>


<li>Set up your sales tax rules (<a href="@ec_url@admin/sales-tax/"
>@ec_url@admin/sales-tax/</a>).  If your
company is located only in one or a few states, this will be easy.  On
the other hand, if you're a Fortune 500 company and you have nexus
(i.e. have an office or factory or store) in many states, you might
want to buy tax tables from <a
href="http://www.salestax.com/">www.salestax.com</a>.  A fair bit of
programming would be needed to integrate this data with your ecommerce
system.  Also if you're not based in the USA, you may need to have
some programming done to handle the tax for the regions in your
country.

<p>


<li>Decide if you want to add any custom product fields.  First look
at the current fields available (<a href="@ec_url@admin/products/add"
    >@ec_url@admin/products/add</a>) to see if
they meet your needs.  The current fields are probably sufficient for
many types of products.  However, a bookseller may wish to add a
custom field to store the ISBN, or someone who sells clothing from
many manufacturers may wish to add a manufacturers field.  Custom
fields are added at <a href="@ec_url@admin/products/custom-fields">@ec_url@admin/products/custom-fields</a>.

<p>

<li>Create new product display templates
(<a href="@ec_url@admin/templates/">@ec_url@admin/templates/</a>)
(unless you're happy with the somewhat minimalist default template).  The
reason for having product display templates is that you might want to present
different types of products in different ways (e.g., spring dresses get a
yellow background page color; winter coats get a blue background page color).

<p>

You can modify the default template that the ecommerce module comes with
to incorporate your custom product fields, to exclude fields you
don't use, or just change
the way it looks to fit whatever design scheme you want to use.  The
template is written in AOLserver's ADP language, which is just HTML
with Tcl variables (or commands) inside &lt;% and %&gt; tags.  It is
extremely easy.  It you can write HTML, you can write ADP.  If you can't,
you can hire someone cheaply to do it for you.

<p>

You can create as many additional templates as you like.
You can associate templates with product categories so that every
product in the "book" category is automatically assigned the
"book" template by default, although you can always assign any
template you want to any product you want (so if you have an
unusual product, you can give it an unusual template).

<p>

<li>Set up user classes (<a href="@ec_url@admin/user-classes/"
    >@ec_url@admin/user-classes/</a>).  User
classes are groupings of the users, such as "student", "retired",
"institution", "publisher", etc. They may get special prices,
different views of the site, or different product recommendations.

<p>

Depending on your settings in the ini file, users may or may not be
able to see which user classes they're a member of (so be careful
of what you call them!).

<p>

If a user is a member of more than one class and there are special
prices on the same product for both classes, the user will receive
whichever price is lowest.

<p>

<li>Enter your products into the database.  This can be done using the
simple form at <a href="@ec_url@admin/products/add"
    >@ec_url@admin/products/add</a>.

<p>

However, if you have many products already stored in another database,
you will not want to enter them one by one.  Instead, export them into
a CSV file (or a series of CSV files), and manipulate them into the
formats documented at <a href="@ec_url@admin/products/upload-utilities"
    >@ec_url@admin/products/upload-utilities</a> so that they can be uploaded in
bulk.

<p>

<li>After you've added a product, there are a variety of things you can
do to it, such as:
  <ul>
  <li>Add any number of professional reviews.
  <li>Add "cross-selling links" so that the customer always sees a link
      to another given product when they're viewing this product, or vice versa.
  <li>Put the product on sale or create "special offers".
  </ul>

<p>

<li>Add product recommendations (<a
    href="@ec_url@admin/products/recommendations"><%= [ec_url]
%>admin/products/recommendations</a>).  If you have many products
subdivided into a number of categories/subcategories/subsubcategories,
it's good to include product recommendations in order to make the site
more browsable and interesting.

<p>

Recommendations are displayed when the customer is browsing the site, either on the
home page (if a product is recommended at the top level), or when the
customer is browsing categories, subcategories, or subsubcategories.

<p>

You can also associate product recommendations with a user class.  E.g.,
you might only want the book "Improving your GRE Scores" to only be recommended
to Students.

<p>

<li>Modify the email templates (<a
href="@ec_url@admin/email-templates/">@ec_url@admin/email-templates/</a>),
which are used when the system sends out automatic email to customers.
There are seven predefined email templates for email sent out when a
customer's order is authorized, when a customer's order ships, when a
customer receives a gift certificate, etc.

<p>

The current templates are functional but should probably be edited to reflect
your company better.

<p>

<li>The layout for all the pages in your site is created using ADP templates
which are stored in the directory packages/ecommerce/www/templates/
(with the exception of product which, as discussed above, uses a different
ADP templating system to allow for different templates for different products).
If you are unhappy with the look of any of the pages in your site, there's
a good chance that it can be changed simply by editing the corresponding ADP
template.

</ol>

<p>

That's it for setup!   Of course, your customers won't be very happy
until you can do things like order fulfillment, so it's time to read about
<a href="ecommerce-operation">operation of your ecommerce site</a>.



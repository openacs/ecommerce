<master>
  <property name=title>@title;noquote@</property>
  <property name="signatory">@signatory;noquote@</property>
  <property name="context_bar">@context_bar;noquote@</property>

  <p>The Customer Service Module can be found at <if @package_url@ not nil><a
   href="@package_url@admin/customer-service/">@package_url@</if>admin/customer-service/<if @package_url@ not nil></a></if>
   (it is also linked to from the main Ecommerce Administration
   page).</p>

  <h3>Issues and Interactions</h3>

  <p>There are two main concepts underlying the customer service
    submodule: customer service interactions and customer service
    issues.</p>

  <p>There is a many-to-many relationship between issues and
    interactions.  During the course of one interaction, a customer
    may bring up any number of issues ("My credit card shows a charge
    for $7.99, but I thought this ant farm was only supposed to cost
    $6.99 AND, while I have you on the phone, I'd like to mention that
    delivery took three days instead of the promised two.").
    Furthermore, if an issue is not resolved the first time it is
    brought up, it might span any number of interactions until it is
    finally closed.</p>

  <p>Issues can be categorized either for reporting purposes or so
    that different departments of your company can handle the issues.
    Open issues are linked to from the front page of the customer
    service submodule to attract attention.  Whenever email is sent to
    the customer (either automatically or by a customer service rep),
    an issue is created (or added to, if it is based on a previous
    issue).  This is so that a complete interaction history containing
    all correspondence to and from the customer can be maintained.
    All issues created due to automatic emails are closed immediately
    so that they don't get in the way of other issues.</p>

  <p>Small note: the intersection between an issue and an interaction
    is called an "action" (i.e., the part of a specific interaction
    that deals with a specific issue).  This rarely comes up.</p>

  <h3>Registered Users and Unregistered Users</h3>

  <p>As a customer service rep, much of your interaction may be with
    people who have used the site but are not registered users (people
    don't become registered users unless they log in when they order,
    when they submit product reviews, etc.), yet you still want to
    capture the details of the interaction with as much identifying
    information about them as you can.</p>

  <p>Whenever you record a new interaction, you are asked to enter as
    much information as you can gather (or feel comfortable gathering)
    about the user.  The system then tries to match this person up
    with either registered users or unregistered people who have had
    interacted previously with customer service.  If no match can be
    made, a new "user identification record" is created.</p>

  <p>Each time you view a user identification record, the system sees
    if it can match that person up with a registered user of the
    system (in case they have registered in the meantime).</p>

  <h3>Sending Email to Customers</h3>

  <p>When you're viewing a customer service issue, you can send the
    customer email regarding that issue by clicking "send email" at
    the top of the page.  The contents of your email will
    automatically be added to the customer's interaction history and
    will become part of the record for that customer service issue.</p>

  <p> If you find yourself using the same phrases over and over again
    when you respond to customers' emails, the <if @package_url@ not nil><a
    href="@package_url@admin/customer-service/canned-responses"></if>Canned
    Response System<if @package_url@ not nil></a></if> will be useful to you.  You can enter your
    commonly used phrases once, and then whenever you send email
    you'll be able to automatically insert any number of these
    phrases.</p>

  <p>If you want to send email to customers in bulk, then use the <if @package_url@ not nil><a
    href="@package_url@admin/customer-service/spam"></if>Spam System<if @package_url@ not nil></a></if>.
    You can spam users based on what products they've bought, what
    products they've even looked at, by when they've last visited, by
    how much they've spent at your site, by which mailing lists
    they're signed up for.  If you're spamming customers that you
    like, you can issue them all gift certificates at the same time.</p>

  <p>Your email text is also sent through a spell checker before it is
    sent to the customer.</p>

  <h3>Picklist Management</h3>

  <p>When your customer service data entry people are recording
    customer interactions, you want it to take as little effort as
    possible.  One way to help is to predefine picklists that they can
    choose from when entering data.  With the <if @package_url@ not nil><a
    href="@package_url@admin/customer-service/picklists"></if>Picklist
    Management tool<if @package_url@ not nil></a></if>, you can specify what goes in what picklist in
    what order.</p>

  <h3>Reports</h3>

  <p>Reports and statistics are generated so that you can tell what
    types of issues are occurring most frequently, which customer
    service reps are handing the most interactions, what resources the
    reps need to use most often, etc.  Each report can be filtered and
    sorted in a variety of ways to give you a clear picture of what's
    happening and what can be done to improve efficiency.</p>


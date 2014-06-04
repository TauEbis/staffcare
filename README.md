Black Box
=========

Getting Started
---------------

```
git@github.com:riobennin/staff_care.git
cd staff_care
git remote add staging git@heroku.com:staff-care-staging.git
git remote add prod git@heroku.com:staff-care-prod.git
bundle install
rake db:migrate
rake db:seed
```

**Username**: user@example.com

**Password**: f4a025eeb5bd

Documentation and Support
-------------------------

This is the only documentation.

#### Issues

Lorem ipsum dolor sit amet, consectetur adipiscing elit.


License
-------

Proprietary code.  No license granted.


Development Details
===================

Ruby on Rails
-------------

This application requires:

-   Ruby
-   Rails

Learn more about [Installing Rails](http://railsapps.github.io/installing-rails.html).

Database
--------

This application uses PostgreSQL with ActiveRecord.

Development
-----------

-   Template Engine: ERB
-   Testing Framework: Test::Unit
-   Front-end Framework: Bootstrap 3.0 (Sass)
-   Form Builder: SimpleForm
-   Authentication: Devise
-   Authorization: Pundit
-   Admin: None

Email
-----

The application is configured to send email using a SMTP account.

Email delivery is disabled in development.

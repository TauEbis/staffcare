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
rake db:create db:migrate
rake db:seed
```

**Username**: admin@admin.com

**Password**: password

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

This application uses PostgreSQL with ActiveRecord.  It also requires Redis.

It's assumed Redis is running on localhost:6379.
If it isn't, set the ENV variable `REDIS_PROVIDER` to your Redis URL.
e.g. redis://redis.example.com:7372/12

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

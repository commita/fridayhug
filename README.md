# Friday Hug

[FridayHug.com](http://fridayhug.com) (former HugFriday.com) is a movement to help spread the goodness. 
Share your hug every Friday on twitter using the hashtag #FridayHug

## Enviroment

* Ruby 1.9.3-p194

* [MongoDB](http://www.mongodb.org/downloads) >= 2.0

* Bundler >= 1.2.0.rc.2 (supports ruby version on Gemfile, read more bellow on Heroku section)
 
## Setup

Install bundler 1.2.0.rc.2 or newer:

`gem install bundler --pre`

Create database config `mongoid.yml`:

`cp config/mongoid.yml.example config/mongoid.yml`

This is the configuration file used by Mongoid, you can check more details [here](http://mongoid.org/en/mongoid/docs/installation.html).

Create AWS config `s3.yml`:

`cp config/s3.yml.example config/s3.yml`

The file is self explicatory, just add your Amazon AWS credentials and your S3 bucket name to host the thumbnails.

Now you are pretty much set, the project should run but with no content.

## Update Script

We have to update our database from time to time, watching a few keywords on Twitter and we won't do that on every user request,
because this would be resource and time consuming.

So, here is where `scripts/update.rb` comes in place, we run it periodicaly (every 10 minutes) using any scheduler you have 
available on your system. We use the the UNIX CRON for it and the command will look something like:

`*/10 * * * * /bin/bash -l -c 'cd /my/app/fridayhug && RACK_ENV=production bundle exec ruby /my/app/fridayhug/scripts/update.rb >/my/app/fridayhug/last_update.txt'`

## Heroku

We use Heroku to host our little app and we use their awesome [free tier](http://www.heroku.com/pricing#1-0).
In order to get the app running on Heroku, there's a few extra configurations you need to do:

Since Heroku uses a very easy but peculiar `git push` deploy style, we can't host configuration files on our source repository,
it's a bad practice (oh yeah, we did that in the past, when our code was still behind the curtain, shme on us).

How Heroku handles configuration then? Here come in scene [Heroku Config Vars](https://devcenter.heroku.com/articles/config-vars).

And our app supports that, if some key vars are present we will use that instead of using the YML files.

What you need to do is:

1. Forget about `mongoid.yml` and `s3.yml`, they are useless on Heroku.

2. Create `MONGOLAB_URL` var:

  `heroku config:set MONGOLAB_URL=mongodb://USER:PASS@ds0a4443.mongolab.com:37407/database_name`

  You can find the mongodb URI on your MongoDB service amin panel.

3. Create AWS vars:

  `heroku config:set AWS_KEY_ID='AKIAIEFGBBBESOJGQ' AWS_SECRET='qr1qdcEWpyCudzyZMdfg2344sdfsdfdsfdsf' AWS_S3_BUCKET='fridayhug'`

4. Create `RACK_ENV` var:
  `heroku config:set RACK_ENV=production`

**OPTIONAL**

There's a very simple admin interface, that enables you to remove or hide hugs from the homepage. But to access it, you need
to setup the admin vars:

`heroku config:set AMDIN_USER=username AMDIN_PASSWORD=password`

And then access the path `/manage-hugs` for the admin.

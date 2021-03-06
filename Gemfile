source 'https://rubygems.org'

gem 'rails', '3.2.13'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# See ELLS appendix A for information on heroku deployment
# for Heroku deployment - as described in Ap. A of ELLS book
group :development, :test do
  gem 'debugger'
  #gem 'cucumber-rails', :require => false
  #gem 'cucumber',  '1.2.5'
  #gem 'cucumber-rails', '1.3.0', :require => false
  gem 'rspec-rails'
  gem 'factory_girl_rails'
end

group :test do
  gem 'capybara'
  gem 'launchy' # to pop up saved webpages?
  gem 'database_cleaner'
  gem 'rb-fsevent', :require => false if RUBY_PLATFORM =~ /darwin/i # required for guard on mac
  gem 'wdm', :require => false if RUBY_PLATFORM =~ /mingw/i # required for guard on windows
  gem 'spork', '~> 1.0rc' # speed up interminable load times for testing
  #gem 'guard-cucumber'
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'faker'
end

# Using postgres for all configurations now.
#gem 'sqlite3'
gem 'pg'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

gem 'haml-rails' # use haml instead of erb.
gem 'mechanize' # used to scrape waiter.com
gem 'sorcery'
gem 'delayed_job_active_record'
#gem "daemons"

# clean up logging
gem 'quiet_assets', :group => :development
# Use thin webserver instead of webrick.  Launch using "rails s thin"
gem 'thin'


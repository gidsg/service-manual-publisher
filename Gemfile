source 'https://rubygems.org'

gem 'rails', '5.0.1'
gem 'pg'
gem 'sass-rails'
gem 'uglifier'

gem 'unicorn'
gem 'logstasher'
gem 'plek'
# We pin airbrake because we tried to upgrade to version 5 and failed to deploy it
# in staging. The gem complained about a configuration error when precompiling the
# asserts. Here is the attempt:
# https://github.com/alphagov/service-manual-publisher/commit/ae7f0f1016d84f71282adfac3640c00047115ebe
gem 'airbrake', '~> 4.2.1'

gem 'govuk_admin_template'

gem 'active_link_to'
gem 'auto_strip_attributes'
gem 'diffy'
gem 'gds-api-adapters'
gem 'gds-sso'
gem 'govspeak'
gem 'highline'
gem 'kaminari'
gem 'redcarpet'
gem 'rinku', require: "rails_rinku"
gem 'select2-rails'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
end

group :development, :test do
  gem 'byebug'
  gem 'fuubar'
  gem 'govuk-lint'
  gem 'jasmine'
  gem 'pry'
  gem 'pry-nav'
  gem 'pry-remote'
  gem 'rspec-rails', '~> 3.5'
  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'govuk-content-schema-test-helpers'
  gem 'launchy'
  gem 'poltergeist'
  gem 'rails-controller-testing'
  gem 'webmock'
end

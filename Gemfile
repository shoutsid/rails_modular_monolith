# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~> 3.2.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 7.1.3'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'
# Use Puma as the app server
gem 'puma', '~> 6.4'
# Compile and serve assets
gem 'sprockets-rails', '~> 3.4.2'
# Use Bootstrapp for stylesheets
gem 'cssbundling-rails', '~> 1.4.0'
# Transpile app-like JavaScript
gem 'jsbundling-rails', '~> 1.3.0'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

# Authentication
gem 'devise', '~> 4.8'

# Job processing
gem 'karafka'
gem 'karafka-web'
gem 'waterdrop'

# AI focused gems
gem 'faraday', '~> 2.9'
gem 'langchainrb', '~> 0.13.3'
gem 'langchainrb_rails', '~> 0.1.10'
gem 'neighbor'
gem 'ollama-ai', '~> 1.2.1'
gem 'tiktoken_ruby'

group :development, :test do
  # Rubocop & Linting
  gem 'rubocop', '~> 1.64', require: false
  gem 'rubocop-factory_bot', '~> 2.25'
  gem 'rubocop-rails', '~> 2.25'
  gem 'rubocop-rake', '~> 0.6.0'
  gem 'rubocop-rspec', '~> 2.30'
  gem 'rubocop-rspec_rails', '~> 2.28'

  # Static Typing
  gem 'tapioca', '~> 0.14.3', require: false

  gem 'byebug', '~> 11.1.3'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'pry-remote', require: 'pry-remote'
  # Modularization
  gem 'packwerk', '~> 3.2'
  # Visual representation of components
  gem 'dotenv-rails', '~> 3.1'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'faker', '~> 3.4'
  gem 'graphwerk', '~> 1.2.0'
end

group :test do
  gem 'karafka-testing'
  gem 'rails-controller-testing', '~> 1.0', '>= 1.0.5'
  gem 'rspec-rails', '~> 6.1'
  gem 'super_diff', '~> 0.12.1'
end

group :development do
  # Annotate models
  gem 'annotate', '~> 3.2.0'
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'letter_opener', '~> 1.4', '>= 1.4.1'
  gem 'listen', '~> 3.3'
  gem 'mailcatcher'
  gem 'make_menu', '~> 2.1.0'
  gem 'rack-mini-profiler', '~> 3.3'

  # Static Typing
  gem 'sorbet', '~> 0.5.11415'
  gem 'sord', '~> 6.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Static Typing
gem 'sorbet-runtime', '~> 0.5.11414'

source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.1'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
gem 'coffee-script-source', '1.8.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
#gem 'therubyracer', platforms: :ruby
#gem "less-rails"

# Devise. Authentication framework
gem 'devise', '>= 3.4.1'

# Locale aware date parsing
gem "delocalize"

# Font Awesome
gem "font-awesome-rails"
# Bootstrap
#gem 'bootstrap-sass', '~> 3.2.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
end

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development
group :test do
  # Rspec
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'shoulda-kept-assign-to'
  gem 'rspec-collection_matchers'
  gem 'timecop'
  gem 'faker'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'spring-commands-rspec'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  
  gem 'sqlite3'
  gem 'spring'
end

group :production do
  # Heroku setup
  gem 'rails_12factor'
  gem 'thin'
  gem 'pg'

  # Docker setup
  gem 'unicorn', platforms: :ruby
  gem 'foreman', platforms: :ruby
end

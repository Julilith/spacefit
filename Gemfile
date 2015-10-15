source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.4'

# DB, CSS & JS
gem 'sass-rails', '~> 5.0'     # Use SCSS for stylesheets
gem 'uglifier', '>= 1.3.0'     # Use Uglifier as compressor for JavaScript assets
gem 'turbolinks'               # Turbolinks makes following links in your web application faster.

# JS
gem 'jbuilder', '~> 2.0'       # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'coffee-rails', '~> 4.1.0' # Use CoffeeScript for .coffee assets and views
gem 'coffee-script-source', '1.8.0'
gem 'jquery-rails'             # Use jquery as the JavaScript library
gem 'jquery-turbolinks'

# fonts and style
gem 'bootstrap-sass'
gem 'font-awesome-sass'

#things we might not need
gem 'simple_form'

gem 'rails_12factor', group: :production
gem 'puma',           group: :production

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
gem 'bcrypt', '~> 3.1.7'

# fix time zone error when opening server
gem 'tzinfo-data', platforms: [:x64_mingw,:mingw, :mswin]

# authentications with facebook/
gem 'omniauth'
gem 'omniauth-facebook'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby


#database & heroku
group :production do
	gem "pg"
	gem "rails_12factor"
end

group :development do
	gem 'sqlite3'
	gem "better_errors"
	gem "binding_of_caller"
	gem "quiet_assets"
	gem "pry-rails"
	gem "pry-byebug"
end

gem "figaro"

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

group :development do
  gem 'web-console', '~> 2.0'   # Access an IRB console on exception pages or by using <%= console %> in views
end

#internationalization
# gem 'rails_i18n'

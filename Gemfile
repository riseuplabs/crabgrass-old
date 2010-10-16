source :gemcutter

# these gems are not necessary if you have the corresponding 
# debian packages installed run
# bundle install --without gems
group :gems do
  gem "rails", '~>2.3.5'
  gem 'RedCloth', '>= 4.2.2'
  gem 'haml', '~>3.0.0'
  gem 'compass'
  gem 'compass-susy-plugin', :require => 'susy'
  gem 'packet', '>=0.1.15'
end

gem 'greencloth', :git => "git://github.com/riseuplabs/greencloth"
gem 'will_paginate'

gem 'thinking-sphinx', '1.3.19' , :require => 'thinking_sphinx', :group => 'search'

group 'wysiwyg' do
  gem 'undress', :git => "git://github.com/riseuplabs/undress"
  gem 'uglify_html', :git => "git://github.com/riseuplabs/uglify_html"
end

# these gems are not necessary if you do not want to run tests.
# in order to do so run
# bundle install --without test
group :test do
  gem 'cucumber', '>=0.6.2'
  gem 'spork', '>=0.7.3'
  gem 'faker', '>=0.3.1'
  gem 'mocha'
  gem 'blueprints'
  gem 'machinist'
  gem 'webrat', '>=0.5.3'
end

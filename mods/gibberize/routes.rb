=begin

include this in config/routes.rb to activate these routes:

  map.from_plugin :gibberize

this will create the routes
  /gibberize              -> Gibberize::BaseController
  /gibberize/keys         -> Gibberize::KeysController
  /gibberize/languages    -> Gibberize::LanguagesController
  /gibberize/translations -> Gibberize::TranslationsController

=end

map.namespace :gibberize do |gibberize|
  gibberize.resources :keys
  gibberize.resources :languages
  gibberize.resources :translations
  gibberize.root :controller => 'base'
end

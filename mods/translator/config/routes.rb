=begin

include this in config/routes.rb to activate these routes:

  map.from_plugin :translator

this will create the routes
  /translator              -> Translator::BaseController
  /translator/keys         -> Translator::KeysController
  /translator/languages    -> Translator::LanguagesController
  /translator/translations -> Translator::TranslationsController

=end

map.namespace :translator do |translator|
  translator.resources :keys
  translator.resources :languages
  translator.resources :translations
  translator.root :controller => 'base'
end

class Translator::BaseController < ApplicationController

  include FlashMessageHelper
  include AuthenticatedSystem

  layout 'translator'
  helper 'translator/keys', 'translator/languages', 'translator/translations', 'translator/base'
  before_filter :login_required

  include Translator::KeysHelper
  include Translator::LanguagesHelper
  include Translator::TranslationsHelper

  def index
    @languages = I18n.available_languages
  end

  def apply_translations
    system('rake cg:l10n:extract_translations RAILS_ENV=%s' % RAILS_ENV)
    system('touch', RAILS_ROOT+'/tmp/restart.txt')
    flash_message :success => true
    redirect_to :action => nil
  end

  def import_english
    system('rake cg:l10n:load_translations FILE=en.yml RAILS_ENV=%s' % RAILS_ENV)
    flash_message :success => true
    redirect_to :action => nil
  end

  protected

  def authorized?
    current_site.translation_group.any? and current_user.member_of?(Group.find_by_name(current_site.translation_group))
  end
end

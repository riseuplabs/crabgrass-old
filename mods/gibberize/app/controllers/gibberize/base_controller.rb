class Gibberize::BaseController < ApplicationController

  include ErrorHelper
  include AuthenticatedSystem

  layout 'gibberize'
  helper 'gibberize/keys', 'gibberize/languages', 'gibberize/translations', 'gibberize/base'
  before_filter :login_required

  include Gibberize::KeysHelper
  include Gibberize::LanguagesHelper
  include Gibberize::TranslationsHelper

  def index
    @languages = LANGUAGES
  end

  def apply_translations
    system('rake cg:l10n:extract_translations RAILS_ENV=%s' % RAILS_ENV)
    system('touch', RAILS_ROOT+'/tmp/restart.txt')
    flash_message :success => true
    redirect_to :action => nil
  end

  protected

  def authorized?
    current_site.translation_group.any? and current_user.member_of?(Group.find_by_name(current_site.translation_group))
  end
end

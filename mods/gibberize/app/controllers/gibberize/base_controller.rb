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

  protected

  def authorized?
    ret = false
    if Site.current.translators.any?
      ret = true if Site.current.translators.include?(current_user.login)
    end
    if Site.current.translation_group.any?
      ret = true if current_user.member_of?(Group.find_by_name(Site.current.translation_group))
    end
    ret
  end
end

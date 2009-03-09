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
    if current_site.translators.any?
      ret = true if current_site.translators.include?(current_user.login)
    end
    if current_site.translation_group.any?
      ret = true if current_user.member_of?(Group.find_by_name(current_site.translation_group))
    end
    ret
  end
end

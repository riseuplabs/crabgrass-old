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
    @languages = Language.find(:all)
  end

  protected

  def authorized?
    @site.translators and @site.translators.include?(current_user.login)
  end
end

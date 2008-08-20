class Gibberize::BaseController < ActionController::Base

  include ErrorHelper
  include AuthenticatedSystem

  layout 'gibberize'
  helper 'gibberize/keys', 'gibberize/languages', 'gibberize/translations', 'gibberize/base'
  before_filter :login_required

  include Gibberize::KeysHelper
  include Gibberize::LanguagesHelper
  include Gibberize::TranslationsHelper

  protect_from_forgery :secret => Crabgrass::Config.secret

  def index
  end

  protected

  def authorized?
    @site = Site.default
    @site.translators and @site.translators.include?(current_user.login)
  end
end

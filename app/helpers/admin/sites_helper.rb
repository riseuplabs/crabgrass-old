module Admin::SitesHelper
  def signup_mode_description(mode)
#    :default => 0, :closed => 1, :invite_only => 2, :verify_email => 3
#
    case mode
    when :default
      I18n.t(:signup_mode_default_description)
    when :closed
      I18n.t(:signup_mode_closed_description)
    when :invite_only
      I18n.t(:signup_mode_invite_only_description)
    when :verify_email
      I18n.t(:signup_mode_verify_email_description)
    else
      I18n.t(:unknown)
    end
  end
end

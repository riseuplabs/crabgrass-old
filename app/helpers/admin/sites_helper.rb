module Admin::SitesHelper
  def signup_mode_description(mode)
    :default => 0, :closed => 1, :invite_only => 2, :verify_email => 3

    case mode
    when :default
      :signup_mode_default_description.t
    when :closed
      :signup_mode_closed_description.t
    when :invite_only
      :signup_mode_invite_only_description.t
    when :verify_email
      :signup_mode_verify_email_description.t
    else
      :unknown.t
    end
  end
end

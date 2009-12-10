class PasswordStrengthViewListener < Crabgrass::Hook::ViewListener
  include Singleton

  def signup_form_password(context)
    %Q[
      <div class="pw_meter">
        <div id="pw_bar">
        </div>
      </div>
      <span id='pw_time_to_crack' style='display:none'>
        #{I18n.t(:signup_time_to_crack_password, :time => "<span id='pw_time'>??</span>")}
      </span>
    ] +
    observe_field('user_password', :function => "set_pw_bar(value, #{MIN_PASSWORD_STRENGTH});", :frequency => 0.25) +
    %w(date_centuries date_years date_months date_weeks date_days date_hours date_minutes date_seconds).collect {|time| hidden_field_tag(time, I18n.t(time.to_sym)) }.join(' ')
  end

  def html_head(context)
    return unless params[:controller] == 'account'
    stylesheet_link_tag('password', :plugin => 'password_strength') +
    javascript_include_tag('password', :plugin => 'password_strength')
  end

end


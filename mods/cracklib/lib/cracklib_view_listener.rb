class CracklibViewListener < Crabgrass::Hook::ViewListener
  include Singleton

  def signup_form_password(context)
    %Q[
      <div class='p'>
        <span id="password_strength"></span>
      </div>
    ] + observe_form(:signup_form, :url => { :controller => :cracklib, :action => :check }, :frequency => 0.5, :update => 'password_strength')
  end

  def html_head(context)
    return unless params[:controller] == 'account'
    %Q[
      <style type="text/css">
      #password_strength .passed {color: green}
      #password_strength .failed {color: red}
      #password_strength .info {color: #f90}}
      </style>
    ]
  end

end

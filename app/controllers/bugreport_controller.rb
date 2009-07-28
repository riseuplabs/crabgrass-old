class BugreportController < ApplicationController

  def submit 
    Mailer.deliver_send_bugreport(params, mailer_options)
    flash_message :title => "Bug Report Sent",
        :success => "Thank you for submitting the bug report!"
    redirect_to(:controller => 'me', :action => 'dashboard') and return
  end

end

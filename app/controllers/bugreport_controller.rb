class BugreportController < ApplicationController

  def submit 
    if current_site.dev_email.empty?
      flash_message :title => "Bug Report not sent.",
        :error => "A development email address has not been specified for this site."
    else
      options = {:dev_email => current_site.dev_email}
      options.merge(mailer_options)
      Mailer.deliver_send_bugreport(params, options)
      flash_message :title => "Bug Report Sent",
        :success => "Thank you for submitting the bug report!"
    end
    redirect_to(:controller => 'me', :action => 'dashboard') and return
  end

end

module Mailers::Bugreport

  # Send an email letting the user know that a page has been 'sent' to them.
  def send_bugreport(params, options)
    setup(options)
    recipients 'kclair@serve.com'
    from  'kclair@serve.com'
    subject 'Crabgrass Bug Report'
    body({:user => @current_user, :backtrace => params[:full_backtrace]})
  end

end

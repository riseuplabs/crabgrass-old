module Admin::EmailBlastsHelper

  def email_blasts_path(arg, options={})
    admin_email_blasts_path(arg,options)
  end

  def edit_email_blasts_path(arg)
    edit_admin_email_blasts_path(arg)
  end

  def new_email_blasts_path
    new_admin_email_blasts_path
  end

  def email_blasts_path
    admin_email_blasts_path
  end

  def email_blasts_url(arg, options={})
    admin_email_blasts_url(arg, options)
  end

end



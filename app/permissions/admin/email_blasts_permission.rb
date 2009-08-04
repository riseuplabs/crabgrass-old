module Admin::EmailBlastsPermission
  def may_index_email_blasts?
    current_user.may?(:admin, current_site)
  end

  alias_method :may_blast_email_blasts?, :may_index_email_blasts?
end

class UnauthenticatedUser
  def login
   I18n.t(:anonymous)
  end
  alias :name :login
  alias :display_name :login

  def may?(access,thing)
    if thing.is_a? Page
      if access == :view
        thing.public?
      else
        false
      end
    else
      false
    end
  end

  def member_of?(group)
    false
  end

  def method_missing(method)
    raise PermissionDenied
  end

  # authenticated users are real, we are not.
  def real?
    false
  end

end

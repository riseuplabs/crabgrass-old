class UnauthenticatedUser
  def may?(perm, page)
    if self.respond_to?(method = "may_#{perm}?")
      return self.send(method, page)
    end
    false
  end

  def may_view?(page)
    return page.public?
  end
  alias :may_read? :may_view?

  def member_of?(group)
    false
  end

  def method_missing(method)
    raise PermissionDenied
  end
end

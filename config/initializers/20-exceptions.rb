class PermissionDenied < Exception; end    # the user does not have permission to do that.
class ErrorMessage     < Exception; end    # just show a message to the user.
class AssociationError < Exception; end    # thrown when an activerecord has made a bad association (for example, duplicate associations to the same object).

class ErrorMessages < Exception
  attr_accessor :title, :errors
  def initialize(title,*errors)
    self.title = title
    self.errors = errors
  end
  def to_s
    self.errors.join("\n")
  end
end

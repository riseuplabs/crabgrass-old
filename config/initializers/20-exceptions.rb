# the user does not have permission to do that.
class PermissionDenied < Exception; end    

# thrown when an activerecord has made a bad association
# (for example, duplicate associations to the same object).
class AssociationError < Exception; end

# just report the error
class ErrorMessage     < Exception; end

# a list of errors with a title. oooh lala!
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


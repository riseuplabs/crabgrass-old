# the user does not have permission to do that.
class PermissionDenied < Exception; end

# thrown when an activerecord has made a bad association
# (for example, duplicate associations to the same object).
class AssociationError < Exception; end

# just report the error
class ErrorMessage < Exception
  def initialize(message, opts={})
    @options = opts
    super(message)
  end
  def options
    @options
  end
end

# report a not found error and return 404
class ErrorNotFound < ErrorMessage
  def initialize(thing)
    @thing = thing
  end
  def to_s
    I18n.t(:thing_not_found, :thing => @thing).capitalize
  end
  def status
    :not_found
  end
end

# a list of errors with a title. oooh lala!
class ErrorMessages < ErrorMessage
  attr_accessor :title, :errors
  def initialize(title,*errors)
    self.title = title
    self.errors = errors
  end
  def to_s
    self.errors.join("\n")
  end
end

class WikiLockError < StandardError; end

class WikiSectionError < StandardError; end

# extend base Exception class to have record() method.
# this is useful like so:
#
#  begin
#    @page = Page.create!( ... )
#  rescue Exception => exc
#    @page = exc.record
#    flash_message_now :exception => exc
#  end
#
#  This way, errors can be handled by the exception, and the field in the form
#  will get little red boxes because @page is set.
#  nifty.
#
class Exception
  def record
    nil
  end
end


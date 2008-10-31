=begin

ways to translate a string:

  "Hello"[:hello]
  "Hello".t
  :hello.t
  "Hello %s" / id
  _('Hello')

Too many! _ and / should not be used.

=end

class String

  def /(*args)
    self.t().%(*args)
  end

  # discard capitalization
  alias :t :[]

  # retain capitalization
  def T()
    self[self.gsub(' ', '_').to_sym]
  end

end 

def _(str)
  str[]
end

class Symbol
  def t()
    self.to_s.t(self)
  end
end


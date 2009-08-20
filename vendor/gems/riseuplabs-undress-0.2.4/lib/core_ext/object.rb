class Object #:nodoc:
  def tap
    yield self
    self
  end
end

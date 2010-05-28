class CorePrinter

  def initialize(partio_string, options={})   
    @partio_string = partio_string
    @options = options
  end

  def to_s
    @partio_string.to_s
  end
  
  def options
    @options
  end

end
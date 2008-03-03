class MockFile
  attr_reader :path
	def initialize(path)
		@path = path
	end
	
	def size
  	1
  end
  
  def read
    'foo'
  end
end
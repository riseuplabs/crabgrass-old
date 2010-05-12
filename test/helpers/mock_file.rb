# This is a testable class that emulates an uploaded file
# Even though this is exactly like a ActionController::TestUploadedFile
# i can't get the tests to work unless we use this.
class MockFile
  attr_reader :path
  def initialize(path); @path = path; end
  def size; 1; end
  def original_filename; @path.split('/').last; end
  def read; File.open(@path) { |f| f.read }; end
  def rewind; end
end
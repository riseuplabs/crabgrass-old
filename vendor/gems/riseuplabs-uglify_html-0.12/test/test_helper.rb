require "rubygems"
require "test/unit"
require "contest"
Dir[File.expand_path(File.dirname(__FILE__) + "/../lib/**/*.rb")].each do |file|
  require file
end

begin
  require "redgreen"
rescue LoadError
end

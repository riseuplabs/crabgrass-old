# put this at the top of your test, before the class def, to see
# the logs printed to stdout. useful for tracking what sql is called when.
# probably way too much information unless run with -n to limit the test.
# ie: ruby test/unit/page_test.rb -n test_destroy
#
def showlog
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end


module DebugTestHelper
  # prints out a readable version of the response. Useful when using the debugger
  def response_body
    puts @response.body.gsub(/<\/?[^>]*>/, "").split("\n").select{|str|str.strip.any?}.join("\n")
  end
end
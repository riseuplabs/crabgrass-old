require File.dirname(__FILE__) + '/../test_helper'
require 'latex_controller'
require 'greencloth/util'

# Re-raise errors caught by the controller.
class LatexController; def rescue_action(e) raise e end; end

class LatexControllerTest < Test::Unit::TestCase
#  fixtures :users, :memberships, :assets

  def setup
    @controller = LatexController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_show
    get :show, :path => [ encode_and_compress_url_data("x^2-2") ]
    assert_response :success
  end

  def encode_and_compress_url_data(string)
    compressed = Zlib::Deflate.deflate(string, Zlib::BEST_SPEED)
    encoded = Base64.encode64(compressed)
    # we escape because encode64 puts in '\n' and '/' and '='
    # we turn each new line into a /, so that we can use page caching
    # (linux filename limit is 255, so we divide into directories)
    #return URI.escape(encoded, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    return encoded.strip.gsub('/','%7C').gsub('=','%3D').gsub("\n",'/')
  end
end

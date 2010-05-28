# Copyright (c) 2009 Todd Willey <todd@rubidine.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require File.join(File.dirname(__FILE__), 'before_render_test_helper')

class RaiseForTestSuccess < StandardError ; end
class RaiseForRender < StandardError ; end

$ran_method_sentinel = false

class TestController < ActionController::Base
  attr_accessor :dont_run_before_render
  before_render :raise_for_test_success, :unless => lambda{|instance| instance.dont_run_before_render }

  def index
    $ran_method_sentinel = true
  end

  private
  def raise_for_test_success
    raise RaiseForTestSuccess, "And happiness abides"
  end
end

context 'A Controller with a before_render callback' do
  setup do
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new

    @request.env['REQUEST_METHOD'] = 'GET'
    @request.action = 'index'

    @controller = TestController.new
  end

  it 'should run callback' do
    assert_raise(RaiseForTestSuccess) do
      @controller.process @request, @response, :perform_action_without_rescue
    end
  end

  it 'should run callback after controller method' do
    @controller.process(@request, @response, :perform_action_without_rescue) rescue nil
    assert $ran_method_sentinel
  end

  it 'should run callback before render occurs' do
    # would get a MissingTemplate if render were actually called
    assert_nothing_raised do
      begin
        @controller.process(@request, @response, :perform_action_without_rescue)
      rescue RaiseForTestSuccess
        # noop
      end
    end
  end

  it 'should skip the before_render filter when conditions not met' do
    @controller.dont_run_before_render = true
    assert_raise(ActionView::MissingTemplate) do
      @controller.process(@request, @response, :perform_action_without_rescue)
    end
  end

end

require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationController do
  it "should call access_denied if PermissionDenied is raised" do
    controller.should_receive :access_denied
    controller.send :rescue_authentication_errors do
      raise PermissionDenied
    end
  end
end

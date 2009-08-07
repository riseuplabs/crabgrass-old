require File.dirname(__FILE__) + '/../../test_helper'

class Admin::UsersControllerTest < ActionController::TestCase

  fixtures :users, :sites, :groups, :memberships

  # none of the tests in here were written for the superadmin mod - they
  # all seemed to be a copy of the normal UserControllerTests.
  #  --azul

end

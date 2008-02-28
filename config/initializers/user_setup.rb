require 'user'
class User < ActiveRecord::Base
  include SocialUser, AuthenticatedUser
end

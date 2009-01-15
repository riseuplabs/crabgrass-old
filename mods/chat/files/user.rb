require "#{RAILS_ROOT}/app/models/user_extension/authenticated_user"

class User < ActiveRecord::Base
  include UserExtension::AuthenticatedUser
end

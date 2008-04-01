class Album < ActiveRecord::Base
  acts_as_modified :only => %w(title artist)
end

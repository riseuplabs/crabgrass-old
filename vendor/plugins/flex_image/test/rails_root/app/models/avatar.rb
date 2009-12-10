=begin
create_table "avatars", :force => true do |t|
  t.binary        "image_file_data"
  t.boolean       "public,            :default => false
end
=end

class Avatar < ActiveRecord::Base
  acts_as_fleximage :image_directory => 'public/uploads'
  validates_presence_of :username
end

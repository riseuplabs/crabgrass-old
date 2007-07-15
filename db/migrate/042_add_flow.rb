# 
# add flow to pages
# flow is used to restrict some pages to be visible only when 
# doing a particular activity, like :membership
#

class AddFlow < ActiveRecord::Migration
  def self.up
    add_column :pages, :flow, :integer
  end

  def self.down
    remove_column :pages, :flow
  end
end


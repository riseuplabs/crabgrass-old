#
# denormalizing bad! but impossibly complex queries are worse!
# we denormalized created_by_login so that we can sort by it
# without loosing our minds from an overly complex query.
# 

class MoreDenormalizePages < ActiveRecord::Migration
  def self.up
    add_column :pages, :created_by_login, :string
    ActiveRecord::Base.record_timestamps = false
    Page.find(:all).each do |page|
      page.created_by_login = page.created_by.login if page.created_by
      page.save
    end
  end

  def self.down
    remove_column :pages, :created_by_login
  end
end

#
# it might be bad to be denormalizing the page table so soon.
# however, there is some stuff that we want to display for every page
# when we show a long list of pages, and we don't want to have to piggyback it
# or eager load it. 
# 

class DenormalizePages < ActiveRecord::Migration
  def self.up
    add_column :pages, :group_id, :integer
    add_column :pages, :group_name, :string
    add_column :pages, :updated_by_login, :string
    ActiveRecord::Base.record_timestamps = false
    Page.find(:all).each do |page|
      if page.groups.any?
        page.group_id   = page.groups.first.id
        page.group_name = page.groups.first.name
      end
      page.updated_by_login = page.updated_by.login if page.updated_by
      page.save
    end
  end

  def self.down
    remove_column :pages, :group_id
    remove_column :pages, :group_name
    remove_column :pages, :updated_by_login
  end
end

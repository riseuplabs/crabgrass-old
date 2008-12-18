#
# It is about time, but pages are finally getting an explicit owner.
# I know, I know, it is very propertarian!
# But it is just too confusing to try to always guess who
# should be treated as the owner of a page. 
#

class AddOwnerToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :owner_id, :integer
    add_column :pages, :owner_type, :string
    add_column :pages, :owner_name, :string
    add_column :page_terms, :owner_name, :string
    add_index :pages, 'owner_name', :name => 'owner_name_4'

    ActiveRecord::Base.record_timestamps = false
    Page.reset_column_information

    Page.find(:all).each do |page|
      unless page.owner
        begin
          owner = page.group || page.created_by
          if owner
            page.owner = owner
            page.save!
            page.update_page_terms
          else
            puts "\n\nWARNING: could not figure out who should be the owner of page id %s:\n\n%s\n\n" % [page.id,page.inspect]
          end
        rescue Exception => exc
          puts "\n\nERROR: Could not update the owner of page id %s: %s\n\n%s\n\n" % [page.id, exc.to_s, page.inspect]
        end
      end
    end

  end

  def self.down
    remove_column :pages, :owner_id
    remove_column :pages, :owner_type
    remove_column :pages, :owner_name
    remove_column :page_terms, :owner_name
  end
end



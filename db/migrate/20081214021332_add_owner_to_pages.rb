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

    conn = Page.connection

    pages = conn.select_all('select * from pages')
    pages.each do |page|
      if page['group_id']
        owner_id = page['group_id']
        owner_type = 'Group'
        owner_name = conn.select_value("select name from groups where id = #{owner_id}")
      elsif page['created_by_id']
        owner_id = page['created_by_id']
        owner_type = 'User'
        owner_name = conn.select_value("select login from users where id = #{owner_id}")
      else
        puts "could not determine owner for page (id: #{page['id']}, title: #{page['title']})"
        next
      end

      Page.connection.execute("UPDATE pages SET owner_id = #{owner_id}, owner_type = '#{owner_type}' WHERE id = #{page['id']}")
      putc '.'; STDOUT.flush
    end

  end

  def self.down
    remove_column :pages, :owner_id
    remove_column :pages, :owner_type
    remove_column :pages, :owner_name
    remove_column :page_terms, :owner_name
  end
end



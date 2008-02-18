class CreateAutoSummaries < ActiveRecord::Migration
  def self.up
    create_table :auto_summaries do |t|
      t.column "page_id",       :integer
      t.column "body",          :text
      t.column "body_html",     :text
      t.column "delta",         :boolean
    end
    
    add_column :pages, :delta, :boolean

# WE'RE NOT USING THIS NEXT BIT, WE'LL DO IT MANUALLY
    # make auto_summaries for all docs by resaving each of them
#    Page.find_all.each { |page| page.save! }
  end

  def self.down
    drop_table :auto_summaries
    remove_column :pages, :delta
  end
end

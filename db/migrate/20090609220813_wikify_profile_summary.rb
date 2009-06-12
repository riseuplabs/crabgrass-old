class WikifyProfileSummary < ActiveRecord::Migration
  def self.up
    change_column :profiles, :summary, :text
    add_column :profiles, :summary_html, :text
  end

  def self.down
    change_column :profiles, :summary, :string
    remove_column :profiles, :summary_html
  end
end


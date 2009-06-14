class AddSummaryHtmlToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :summary_html, :string
  end

  def self.down
    remove_column :profiles, :summary_html
  end
end

class AddCaptionToAssets < ActiveRecord::Migration

  def self.up
    add_column :assets, :caption,  :string
    add_column :assets, :taken_at, :datetime
    add_column :assets, :credit,   :string
  end

  def self.down
    remove_column :assets, :caption
    remove_column :assets, :taken_at
    remove_column :assets, :credit
  end

end

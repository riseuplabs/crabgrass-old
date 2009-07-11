class AddMediaFlagsToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :is_image, :boolean
    add_column :pages, :is_audio, :boolean
    add_column :pages, :is_video, :boolean
    add_column :pages, :is_document, :boolean

    begin
      Page.reset_column_information
      AssetPage.find(:all).each do |page|
        asset = Asset.connection.select_all('SELECT * FROM assets WHERE id = %s' % page.data_id).first
        page.is_image = asset['is_image']
        page.is_audio = asset['is_audio']
        page.is_video = asset['is_video']
        page.is_document = asset['is_document']
        if page.changed?
          for field in ['is_image', 'is_audio', 'is_video', 'is_document']
            Page.connection.execute "UPDATE pages SET pages.#{field} = 1 WHERE pages.id = #{page.id}" if page.send(field)
          end
        end
      end
      Page.connection.execute "UPDATE pages SET pages.is_video = 1 WHERE pages.type = 'ExternalVideoPage'"
      Page.connection.execute "UPDATE pages SET pages.is_image = 1 WHERE pages.type = 'Gallery'"
    rescue Exception => exc
      puts exc.inspect
    end
  end

  def self.down
    remove_column :pages, :is_image
    remove_column :pages, :is_audio
    remove_column :pages, :is_video
    remove_column :pages, :is_document
  end
end

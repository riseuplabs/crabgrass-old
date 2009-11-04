class AssetAnswer < SurveyAnswer
  belongs_to :asset, :dependent => :destroy

  def display_value
    I18n.t(:no_data_uploaded_label)
  end

  def value=(val)
    self.asset.destroy if asset
    begin
      self.asset = Asset.make!({:uploaded_data => val})
      self.asset.generate_thumbnails
      write_attribute(:value, val.original_path) if val.respond_to?(:original_path)
    rescue ActiveRecord::RecordInvalid => exc
      write_attribute(:value, nil)
    end
  end
end

class AssetAnswer < SurveyAnswer  
  belongs_to :asset

  def display_value
    "No data uploaded"[:no_data_uploaded]
  end

  def value=(val)    
    self.asset.destroy if self.asset
    unless val.empty?
      self.asset = Asset.make!({:uploaded_data => val})
      self.asset.generate_thumbnails
      write_attribute(:value, val.original_path)
    else
      write_attribute(:value, val)
    end
  end
end

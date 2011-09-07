module SiteHasOneSoundcloudClient
  def self.add_to_class_definition
    lambda do
      has_one :soundcloud_client, :as => :owner
    end
  end
end


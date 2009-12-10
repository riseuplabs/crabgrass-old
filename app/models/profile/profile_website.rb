=begin

=end

class ProfileWebsite < ActiveRecord::Base

  set_table_name 'websites'

  validates_presence_of :site_title
  validates_presence_of :site_url

  belongs_to :profile

  before_save :transform_url
  after_save {|record| record.profile.save if record.profile}
  after_destroy {|record| record.profile.save if record.profile}

  def icon
    'mime_html'
  end

  private

  def transform_url
    unless site_url.blank? || site_url =~ /^http:\/\//
      self.site_url = "http://#{site_url}"
    end
  end

end


class Thumbnail < ActiveRecord::Base

  #
  # Our parent could be the main asset, or it could be a *version* of the
  # asset. 
  # If we are a thumbnail of the main asset:
  #   self.parent_id = id of asset
  #   self.parent_type = "Asset"
  # If we are the thumbnail of an asset version:
  #   self.parent_id = id of the version
  #   self.parent_type = "Asset::Version"
  #
  belongs_to :parent, :polymorphic => true

  after_destroy :rm_file
  def rm_file
    fname = parent.private_thumbnail_filename(filename)
    FileUtils.rm(fname) if File.exists?(fname)
  end

  # returns the thumbnail object that we depend on, if any.
  def depends_on
    @depends ||= parent.thumbnail(thumbdef.depends, true)
  end

  # finds or initializes a Thumbnail
  def self.find_or_init(thumbnail_name, parent_id, asset_class)
    self.find_or_initialize_by_name_and_parent_id_and_parent_type(
      thumbnail_name.to_s, parent_id, asset_class
    )
  end

  # generates the thumbnail file for this thumbnail object
  def generate(force=false)
    return if File.exists?(self.private_filename) and !force
    if depends_on
      depends_on.generate
      input_type  = depends_on.content_type
      input_file  = depends_on.private_filename
    else
      input_type  = parent.content_type
      input_file  = parent.private_filename
    end
    output_type = self.thumbdef.mime_type
    output_file = self.private_filename

    process_chain = Media::Process::Chain.new(input_type, output_type)
    if process_chain.run(input_file, output_file, thumbdef)
      # success
      if Media::Process.has_dimensions?(output_type)
        set_dimensions Media::Process.dimensions(output_file)
      end
    else
      # failure
      self.update_attribute(:failure, true)
    end
  end

  # by the time we figure out what the thumbnail dimensions are,
  # the duplicate thumbnails for the version have already been created.
  # so, when our dimensions change, update the versioned thumb as well.
  def set_dimensions(dims)
    self.width, self.height = dims
    self.failure = false
    self.save
    if vthumb = versioned()
      vthumb.width, vthumb.height = dims
      vthumb.save
    end
  end

  def versioned
    asset = parent.versions.detect{|v|v.version == parent.version}
    asset.thumbnail(self.name) if asset
  end

  # delegate path stuff to the parent
  def private_filename
    parent.private_thumbnail_filename(self.name)
  end

  def public_filename
    parent.public_thumbnail_filename(self.name)
  end

  def url
    parent.thumbnail_url(self.name)
  end

  def exists?
    parent.thumbnail_exists?(self.name)
  end

  def thumbdef
    parent.thumbdefs[self.name.to_sym]
  end

  def ok?
    not failure?
  end
end


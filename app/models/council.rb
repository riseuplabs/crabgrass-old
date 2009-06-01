class Council < Committee

  def initialize(*args)
    super
    write_attribute(:is_council, true)
  end

end


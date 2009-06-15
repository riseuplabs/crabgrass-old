class Council < Committee

  def initialize(*args)
    super
    write_attribute(:is_council, true)
  end

  # some legacy councils do not have self.type == 'Council'
  def group_type
    "Council"
  end

end


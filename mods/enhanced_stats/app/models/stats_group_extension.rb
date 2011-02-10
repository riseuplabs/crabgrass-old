module StatsGroupExtension
 
  def self.add_to_class_definition
    lambda do
      acts_as_created_between
    end
  end

end

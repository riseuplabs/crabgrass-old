module StatsUserExtension
 
  def self.add_to_class_definition
    lambda do

      named_scope(:created_between, lambda do |from, to| {
        :conditions => {:created_at => from..to}
      } end)

    end
  end

end

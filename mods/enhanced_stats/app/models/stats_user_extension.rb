module StatsUserExtension
 
  def self.add_to_class_definition
    lambda do

      named_scope(:created_between, lambda do |from, to|
        to += ' 23:59:59'
        {:conditions => {:created_at => from..to}}
      end)

    end
  end

end

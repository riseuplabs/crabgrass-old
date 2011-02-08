module EnhancedStatsActiverecordExtensions

 def self.included (base)
    base.class_eval do

      named_scope(:created_between, lambda do |from, to| {
        :conditions => {:created_at => from..to}
      } end)  

    end
  end

end
ActiveRecord::Base.send(:include, EnhancedStatsActiverecordExtensions)

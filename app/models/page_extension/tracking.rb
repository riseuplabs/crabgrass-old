module PageExtension::Tracking
  def self.included(base)
    base.extend ClassMethods
    base.send(:include, InstanceMethods)
    base.instance_eval do
      has_many :dailies
      has_many :hourlies
    end
  end

  module InstanceMethods
    # gets the number of stars for one page
    def stats_per_day
      self.dailies
    end

    def stats_per_hour
      self.hourlies
    end
  end
end

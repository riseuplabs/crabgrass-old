module PageExtension::Tracking
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.instance_eval do
      has_many :dailies
      has_many :hourlies
    end
  end

  module InstanceMethods

    # returns an array of view counts, [daily, weekly, monthly, all time]
    def views_stats
      [  hourlies.sum(:views),
         dailies.sum(:views, :conditions => ['created_at > ?',1.week.ago]),
         dailies.sum(:views),
         views_count ]
    end

    # returns an array of view counts, [daily, weekly, monthly, all time]
    def stars_stats
      [  hourlies.sum(:stars),
         dailies.sum(:stars, :conditions => ['created_at > ?',1.week.ago]),
         dailies.sum(:stars),
         stars_count ]
    end

    def edits_stats
      [  hourlies.sum(:edits),
         dailies.sum(:edits, :conditions => ['created_at > ?',1.week.ago]),
         dailies.sum(:edits) ]
    end

    #def stats_per_day
    #  self.dailies
    #end
    #
    #def stats_per_hour
    #  self.hourlies
    #end
  end
end

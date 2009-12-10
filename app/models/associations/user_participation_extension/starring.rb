module UserParticipationExtension
  module Starring

    def self.included(base)
      base.class_eval do
        after_save :update_stars
      end
    end

    def update_stars
      if page
        new_stars_count = page.get_stars
        page.update_attribute(:stars_count, page.get_stars) unless new_stars_count == page.stars_count
      end
    end
  end
end

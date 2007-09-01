# ActsAsRateable
module Juixe
  module Acts #:nodoc:
    module Rateable #:nodoc:

      def self.included(base)
        base.extend ClassMethods  
      end

      module ClassMethods
        def acts_as_rateable
          has_many :ratings, :as => :rateable, :dependent => :destroy
          include Juixe::Acts::Rateable::InstanceMethods
          extend Juixe::Acts::Rateable::SingletonMethods
        end
      end
      
      # This module contains class methods
      module SingletonMethods
        # Helper method to lookup for ratings for a given object.
        # This method is equivalent to obj.ratings
        def find_ratings_for(obj)
          rateable = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
         
          Rating.find(:all,
            :conditions => ["rateable_id = ? and rateable_type = ?", obj.id, rateable],
            :order => "created_at DESC"
          )
        end
        
        # Helper class method to lookup ratings for
        # the mixin rateable type written by a given user.  
        # This method is NOT equivalent to Rating.find_ratings_for_user
        def find_ratings_by_user(user) 
          rateable = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
          
          Rating.find(:all,
            :conditions => ["user_id = ? and rateable_type = ?", user.id, rateable],
            :order => "created_at DESC"
          )
        end
        
        # Helper class method to lookup rateable instances
        # with a given rating.
        def find_by_rating(rating)
          rateable = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
          ratings = Rating.find(:all,
            :conditions => ["rating = ? and rateable_type = ?", rating, rateable],
            :order => "created_at DESC"
          )
          rateables = []
          ratings.each { |r|
            rateables << r.rateable
          }
          rateables.uniq!
        end
      end
      
      # This module contains instance methods
      module InstanceMethods
        # Helper method that defaults the current time to the submitted field.
        def add_rating(rating)
          ratings << rating
        end
        
        # Helper method that returns the average rating
        # 
        def rating
          average = 0.0
          ratings.each { |r|
            average = average + r.rating
          }
          if ratings.size != 0
            average = average / ratings.size 
          end
          average
        end
        
        # Check to see if a user already rated this rateable
        def rated_by_user?(user)
          rtn = false
          if user
            self.ratings.each { |b|
              rtn = true if user.id == b.user_id
            }
          end
          rtn
        end
      end
    end
  end
end

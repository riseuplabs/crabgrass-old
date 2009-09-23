class MoveDataFromRatingsToModeratedFlags < ActiveRecord::Migration

  def self.up
    ratings = Rating.find(:all)
    ratings.each do |r|
      next unless r.rating == -100
      options = {:foreign_id => r.rateable_id, :foreign_type => r.rateable_type, :user_id => r.user_id, :created_at => r.created_at}
      if r.rateable_type == 'Page'
        ModeratedPage.create!(options)
      elsif r.rateable_type == 'Post'
        ModeratedPost.create!(options)
      elsif r.rateable_type == 'Chat'
        ModeratedChat.create!(options)
      end
    end
  end

  def self.down
    all_flagged = []
    all_flagged.concat( ModeratedPages.find(:all) )
    all_flagged.concat( ModeratedPosts.find(:all) )
    all_flagged.concat( ModeratedChats.find(:all) )

    all_flagged.each do |f|
      options = {:rateable_id => f.foreign_id, :rateable_type => f.foreign_type, :user_id => f.user_id, :created_at => f.created_at, 
                 :rating => -100 }
      Rating.create!(options)
    end
  end

end

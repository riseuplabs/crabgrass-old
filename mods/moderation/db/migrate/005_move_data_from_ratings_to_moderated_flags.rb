class MoveDataFromRatingsToModeratedFlags < ActiveRecord::Migration

  def self.up
    ratings = Rating.find(:all)
    ratings.each do |r|
      next unless r.rating == -100
      options = {:foreign_id => r.rateable_id, :user_id => r.user_id, :created_at => r.created_at}
      if r.rateable_type == 'Page'
        ModeratedPage.create!(options)
      elsif r.rateable_type == 'Post'
        ModeratedPost.create!(options)
      end
    end
    pages = Page.find(:all)
    pages.each do |page|
      if page.flow == 3
        if mpage = ModeratedPage.find_by_foreign_id(page.id)
          mpage.update_attribute(:deleted_at, Time.now) unless mpage.deleted_at =~ /\d+/
        else
          options={:foreign_id=>page.id,:deleted_at=>Time.now}
          ModeratedPage.create!(options)
        end
      elsif page.vetted == true
        if mpage = ModeratedPage.find_by_foreign_id(page.id)
          mpage.update_attribute(:vetted_at, Time.now)
        else
          options = {:foreign_id=>page.id,:vetted_at=>Time.now}
          ModeratedPage.create!(options)
        end
      end
    end
    posts = Post.find(:all)
    posts.each do |post|
      if post.deleted_at =~ /\d+/
        if mpost = ModeratedPost.find_by_foreign_id(post.id)
          mpost.update_attribute(:deleted_at, post.deleted_at) unless mpost.deleted_at =~ /\d+/
        else
          ModeratedPost.create!({:foreign_id=>post.id, :deleted_at => post.deleted_at})
        end
      elsif post.vetted == true
        if mpost = ModeratedPost.find_by_foreign_id(post.id)
          mpost.update_attribute(:vetted_at, Time.now)
        else
          options = {:foreign_id=>post.id,:vetted_at=>Time.now}
          ModeratedPost.create!(options)
        end
      end
    end
  end

  def self.down
    all_flagged = []
    all_flagged.concat( ModeratedPage.find(:all) )
    all_flagged.concat( ModeratedPost.find(:all) )

    all_flagged.each do |f|
      next unless f.user_id
      type = 'Page' if f.foreign.is_a?(Page)
      type = 'Post' if f.foreign.is_a?(Post)
      options = {:rateable_id => f.foreign_id, :rateable_type => type, :user_id => f.user_id, :created_at => f.created_at, :rating => -100 }
      Rating.create!(options)
      f.delete
    end
  end

end

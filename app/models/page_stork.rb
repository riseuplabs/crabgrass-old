# 
# Where do pages come from? The PageStork, of course!
# Here in lies all the reusable macros for creating complex pages
#

class PageStork

  def self.link(*args)
    args.collect do |entity|
      "<b><a href='/#{entity.name}'>#{entity.name}</a></b>"
    end
  end
  
  def self.bold(*args)
    args.collect do |a|
      "<b>#{a}</b>"
    end
  end
    
  def self.wiki(options)
    user = (options.delete(:user).cast! User if options[:user])
    group = options.delete(:group).cast! Group
    name = options.delete(:name).cast! String
    page = WikiPage.create do |p|
      p.title = name.titleize
      p.name = name.nameize
      p.created_by = user
      p.data = Wiki.create(:user => user)
    end
    if group
      user.may_pester!(group)
      page.add(group, :access => :admin)
      page.add(user, :access => :admin) unless user.member_of? group
    else
      page.add(user, :access => :admin)
    end
    page.save!
    return page
  end
  
  def self.private_message(options) 
    from = options.delete(:from).cast! User 
    to = options.delete(:to) 
    page = MessagePage.new do |p| 
      p.title = options[:title] || 'Message from %s to %s' % [from.login, to.login] 
      p.created_by = from 
      p.discussion = Discussion.new 
      post = Post.new(:body => options[:body]) 
      post.discussion = p.discussion 
      post.user = from 
      p.discussion.posts << post 
    end 
    page.save
    page.add(from, :access => :admin) 
    page.add(to, :access => :admin) 
    page 
  end
  	
end


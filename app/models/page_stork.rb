#
# Where do pages come from? The PageStork, of course!
# Here in lies all the reusable macros for creating complex pages
#
# TODO: get rid of this silly class
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

  def self.private_message(options)
    from = options.delete(:from).cast! User
    to = options.delete(:to)
    page = MessagePage.create!(:user => from, :share_with => to, :inbox => true) do |p|
      p.title = options[:title]
      p.build_post(options[:body], from)
    end
    page
  end

end


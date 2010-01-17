module PagesHelper

  #
  # some definitions for the action bar.
  #
  def selections
    [:all, :none, :unread]
  end

  def selectors
    { :all => ".page_check",
      :unread => "section.pages_info.unread .page_check",
      :none => ''
    }
  end

  def marks
    [:read, :unread, :watched, :unwatched]
  end

  def views
    if @tab == :my_work
      [:my_work, :watched, :editor, :owner, :unread]
    elsif @tab == :all
      [:public, :networks, :groups]
    end
  end
end

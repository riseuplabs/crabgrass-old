
class DiscussionPage < Page

  # indexing hooks

  def body_terms
    discussion ? discussion.posts * "\n" : ""
  end

  def comment_terms
    ""
  end

end


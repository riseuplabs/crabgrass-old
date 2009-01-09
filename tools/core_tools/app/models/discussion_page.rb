class DiscussionPage < Page #:nodoc:

  # limit comments to people who can edit
  def comment_access
    :edit
  end

  # indexing hooks

  def body_terms
    discussion ? discussion.posts * "\n" : ""
  end

  def comment_terms
    ""
  end

end


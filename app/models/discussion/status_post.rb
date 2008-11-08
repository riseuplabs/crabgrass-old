class StatusPost < Post
  # what differs a status_post from a normal post?
  
  # different class / layout for the view, different partial for the view
  # can only be posted by the discussion (profiles) owner (restrict)
  # --- is a walls discussion owner the profile owner??
  
  # status message = post.body
  
  # next steps:
  
  # - git pull and then run or regenerate migrations
  # - check if sit is working
  # - build some css to check whether the class-splitting works
  # - test it all together
  
  # - find out somehow where to place the wall overview on the dashboard
  # -- and if its ment to be showing all the conversations the user is involved, and hist / her own public wall, or if it perhaps show those in different manners
  
end

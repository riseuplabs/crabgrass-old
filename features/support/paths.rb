module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in webrat_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the homepage/
      '/'
    when /the logout page/
      account_path(:action => 'logout')
    when /the login page/
      login_path
    when /my dashboard page/
      '/me/dashboard'
    when /my work page/
      '/me/work'
    when /my requests page/
      '/me/requests/to_me'
    when /the destroyed groups directory/
      '/groups/directory/destroyed'
    when /the moderation panel/
      '/admin/pages'

    when /^the page of #{capture_model}$/          # translate to named route
      "/page/#{model($1).friendly_url}"

    ## PICKLE PATHS
    when /^#{capture_model}(?:'s)? page$/                           # eg. the forum's page
      path_to_pickle $1

    when /^#{capture_model}(?:'s)? #{capture_model}(?:'s)? page$/   # eg. the forum's post's page
      path_to_pickle $1, $2

    when /^#{capture_model}(?:'s)? #{capture_model}'s (.+?) page$/  # eg. the forum's post's comments page
      path_to_pickle $1, $2, :extra => $3                           #  or the forum's post's edit page

    when /^#{capture_model}(?:'s)? landing page$/                     # eg. the groups's landing page
      name = model($1).name
      "/#{name}"

    when /^#{capture_model}(?:'s)? membership list page$/                     # eg. the groups's membership list page
      name = model($1).name
      "/groups/memberships/list/#{name}"

    when /^#{capture_model}(?:'s)? (.+?) page$/                     # eg. the forum's posts page
      path_to_pickle $1, :extra => $2                               #  or the forum's edit page

    ## OTHER PATHS
    when /^the (.+?) page$/                                         # translate to named route
      send "#{$1.downcase.gsub(' ','_')}_path"

    # Add more mappings here.
    # Here is a more fancy example:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))


    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)

module NavigationHelpers
  include PageHelper
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
      '/me/my_work'
    when /my work page/
      '/pages/my_work'
    when /my all pages page/
      '/pages/all'
    when /my requests page/
      '/me/requests'
    when /the destroyed groups directory/
      '/groups/directory/destroyed'
    when /the moderation panel/
      '/admin/pages'
    when /the (group|network) directory/
      "/#{$1}s/directory/search"
    when /the people directory/
      "/people/directory/browse"
    when /the my (groups|networks|people) directory/
      "/#{$1}/directory/my"
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

    when /^#{capture_model}(?:'s)? (edit|show) tab$/                      # eg. that wikis pages's edit tab
      page_url(model($1), :action => $2)

    when /^#{capture_model}(?:'s)? administration page$/                     # eg. the groups's landing page
      object = model($1)
      name = object.name
      # NOTE: this will only work for groups right now
      controller_name = object.class.table_name
      "#{controller_name}/#{name}/edit"

    when /^#{capture_model}(?:'s)? edit profile page$/                     # eg. the groups's edit page
      name = model($1).name
      "/groups/profiles/edit/#{name}"

    when /^#{capture_model}(?:'s)? membership list page$/                     # eg. the groups's membership list page
      name = model($1).name
      "/groups/memberships/list/#{name}"

    when /^#{capture_model}(?:'s)? (.+?) page$/                     # eg. the forum's posts page
      path_to_pickle $1, :extra => $2                               #  or the forum's edit page

    when /^requests (from me|to me) page$/
      view = $1.downcase.gsub(' ','_')
      "/me/requests?view=#{view}"
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

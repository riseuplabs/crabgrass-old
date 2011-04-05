namespace :cg do
  task :create_default_site_widgets => :environment do
    unless name = ENV['SITE']
      puts 'ERROR: site name required, use SITE=<name> to specify the name or SITE=ALL'
      exit
    end
    if name == 'ALL'
      Site.all.each do |s|
        add_widgets(s)
      end
    elsif s = Site.find_by_name(name)
      add_widgets(s)
    end
  end
end

def self.add_widgets(s)
  unless s.network && s.network.profiles.public
    puts "ERROR: site #{s.name} does not have a network with a public profile."
    return
  end
  puts "Creating widgets for site #{s.name}..."
  profile_id = s.network.profiles.public.id
  lorem = 'Lorem Ipsum dolor sit amet, con sectetuer adipiscing elit. Aenean commodo ligula eget sem dolor. Aeneam massa. Cum sociis justo natoque penatibus. Loram Ipsum'
  widgets_1 = [ # widgets in section one, in order
    {:name => 'IntroWidget', :options => {:title => I18n.t(:welcome_title, :site_title =>s.name)}},
    {:name => 'MapWidget', :options => {:title => 'Projects in '+s.name, :kml => 'groups'}},
    {:name => 'TextBoxWidget', :options => {:title => 'Who is Who?', :text => lorem}},
    {:name => 'TagCloudWidget', :options => {:title => 'Most Used Tags'}},
    {:name => 'ImageTitleWidget', :options => {:title => 'Your Opinion Counts &ndash;<br>talk to us'}},
    {:name => 'PageListWidget', :options => {}}
  ]
  widgets_2 = [
    {:name => 'ButtonWidget', :options => {:title => I18n.t(:contribute_to_site), :link => '/groups/unido/pages/new'}},
    {:name => 'ButtonWidget', :options => {:title => 'Add a job opportunity', :link => '/job/add'}},
    {:name => 'MenuWidget', :options =>  {:title => 'Quickfinder'}},
    {:name => 'NetworkingWidget', :options => {:title => I18n.t(:most_active_members), :type => :users, :recent => false }},
    {:name => 'NetworkingWidget', :options => {:title => I18n.t(:most_active_groups), :type => :groups, :recent => false }},
    {:name => 'TextBoxWidget', :options => {:title => 'What is new?', :text => lorem }}
  ]
  widgets_1.each_with_index do |w, i|
    create_with_options(w.merge({:section => 1, :position => i+1, :profile_id => profile_id}))
  end
  widgets_2.each_with_index do |w, i|
    create_with_options(w.merge({:section => 2, :position => i+1, :profile_id => profile_id}))
  end
end

def self.create_with_options(options)
  if ENV['DEBUG']
    puts 'Creating widget with options '+options.inspect
  else
    puts "Creating widget #{options[:name]}."
  end
  Widget.create(options)
end

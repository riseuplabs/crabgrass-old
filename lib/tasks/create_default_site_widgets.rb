namespace :cg do
  task :create_default_site_widgets => :environment do
    Site.all.each do |s|
      next unless s.network && s.network.profiles.public
      profile_id = s.network.profiles.public.id
      lorem = 'Lorem Ipsum dolor sit amet, con sectetuer adipiscing elit. Aenean commodo ligula eget sem dolor. Aeneam massa. Cum sociis justo natoque penatibus. Loram Ipsum'
      widgets_1 = [ # widgets in section one, in order 
        #{:name => 'IntroWidget', :options => {:title => I18n.t(:welcome_title, :site_title =>s.name)}},
        {:name => 'MapWidget', :options => {:title => 'Projects in '+s.name, :kml => :groups}},
        {:name => 'TeaserWidget', :options => {:title => 'Who is Who?', :text => lorem}},
        {:name => 'TagCloudWidget', :options => {:title => 'Your Opinion Counts &ndash;<br>talk to us'}},
        {:name => 'PageListWidget', :options => {}}
      ]
      widgets_2 = [
        {:name => 'ButtonWidget', :options => {:title => I18n.t(:contribute_to_site), :link => '/groups/unido/pages/new'}},
        {:name => 'ButtonWidget', :options => {:title => 'Add a job opportunity', :link => '/job/add'}},
        {:name => 'MenuWidget', :options =>  {:title => 'Quickfinder'}},
        {:name => 'NetworkingWidget', :options => {:title => I18n.t(:most_active_members), :type => :users, :recent => false }},
        {:name => 'NetworkingWidget', :options => {:title => I18n.t(:most_active_groups), :type => :groups, :recent => false }},
        {:name => 'TeaserWidget', :options => {:title => 'What is new?', :text => lorem }}
      ]
      widgets_1.each_with_index do |w, i|
        create_with_options(w.merge({:section => 1, :position => i+1, :profile_id => profile_id}))
      end
      widgets_2.each_with_index do |w, i|
        create_with_options(w.merge({:section => 2, :position => i+1, :profile_id => profile_id}))
      end
    end
  end
end

def self.create_with_options(options)
  puts 'Creating widget with options '+options.inspect
  Widget.create(options)
end

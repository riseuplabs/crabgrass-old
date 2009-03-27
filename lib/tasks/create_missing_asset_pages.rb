task :create_missing_asset_pages => :environment do
  $stdout.puts "Creating asset pages."
  new_pages = Asset.all.select { |asset|
    if asset.page
      $stdout.puts "Skipping #{asset.id}, page exists."
      nil
    else
      begin
        page = AssetPage.create!(:title => asset.basename, :flow => :gallery, :data => asset)
        $stdout.puts "Created page for #{asset.id}"
        page
      rescue => exc
        $stderr.puts "Error while creating page for #{asset.id}: #{exc.class}"
        $stderr.puts "View backtrace? [Y/n]"
        unless $stdin.gets.strip =~ /n/i
          $stderr.puts exc.backtrace.join("\n")
          $stderr.puts "Press ENTER to continue, CTRL+C to quit."
          $stdin.gets
        end
      end
    end
  }
  $stdout.puts "Successfully created #{new_pages.size} pages."
  $stdout.puts "Do you want to create group_participations now? [Y/n]"
  unless $stdin.gets.strip =~ /n/i
    $stdout.puts "Do you want to include already existing pages? [Y/n]"
    unless $stdin.gets.strip =~ /n/i
      @pages = Asset.media_type(:image).map(&:page)
    else
      @pages = new_pages
    end
  else
    return
  end
  @pages.each { |page|
    galleries = page.asset.galleries
    next unless galleries.any?
    galleries.map(&:group_participations).flatten.map(&:group).uniq.each do |g|
      part = page.group_participations.create!(:group_id => g.id,
                                               :access => ACCESS[:edit])
      $stdout.puts "Group #{g.id} has now access to AssetPage #{page.id}."
    end
  }
  $stdout.puts "Nothing more to do."
end


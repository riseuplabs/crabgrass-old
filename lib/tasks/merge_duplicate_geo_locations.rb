namespace :cg do
  task :merge_duplicate_geo_locations => :environment do
    # look for duplicate geo location rows
    all_gl = GeoLocation.find(:all)
    all_gl.each do |gl|
      next unless GeoLocation.find_by_id(gl.id)
      geo_country_cond = "geo_country_id=#{gl.geo_country_id}"
      # consider all locations with the same city id to be duplicates, and make sure there is an admin code set
      if (!gl.geo_place_id.nil?)
        gl.geo_admin_code_id = gl.geo_place.geo_admin_code_id
        gl.save!
        geo_admin_cond = "(geo_admin_code_id IS NULL or geo_admin_code_id=#{gl.geo_admin_code_id})"
      else
        # we need to explictly include IS NULL where conditions because otherwise if a nil key is included, rails drops the condition
        # if other conditions are dropped, we end up with results that are too inclusive because they only look for one matching column.
        geo_admin_cond = !gl.geo_admin_code_id.nil? ? "geo_admin_code_id=#{gl.geo_admin_code_id}" : "geo_admin_code_id IS NULL"
      end
      geo_place_cond = !gl.geo_place_id.nil? ? "geo_place_id=#{gl.geo_place_id}" : "geo_place_id IS NULL"
      not_current_id_cond = "id != "+gl.id.to_s
      conditions = [geo_country_cond, geo_admin_cond, geo_place_cond, not_current_id_cond].join(' and ')
      dups = GeoLocation.find(:all, :conditions => conditions) 
      dups.each do |dgl|
        Profile.find(:all, :conditions => {:geo_location_id => dgl.id}).each do |p|
          p.geo_location = gl
          p.save!
          unless p.geo_location == gl
            puts 'new geo location for profile '+p.id.to_s+' did not get changed!'
            exit 0
          end
          puts 'updated profile '+p.id.to_s+' with geo_location '+gl.id.to_s
        end
        puts 'destroying duplicate geo_location '+dgl.id.to_s+'. updated to '+gl.id.to_s
        GeoLocation.delete(dgl.id)
      end
    end
  end
end

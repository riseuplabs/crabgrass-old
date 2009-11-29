namespace :cg do

  desc "Imports GeoNames files containing geographic data into models."
  task :import_geo_data => :environment do
#    require 'net/http'
    path = "#{RAILS_ROOT}/tmp/geo_data"
    uri = "/export/dump"
    countries = "/countryInfo.txt"
    admin_codes = "/admin1Codes.txt"
    if Conf.use_full_geonames_data == true
      places = "/allCountries"
    else
      places = "/cities1000"
    end
    Dir.mkdir(path) if ! File.directory?(path)
    [countries, admin_codes, places+".zip"].each do |geofile|
      Net::HTTP.start("download.geonames.org") { |http|
        resp = http.get(uri+geofile)
        open(path+geofile, "w") { |file|
          file.write(resp.body)
        }
      }
    end
    system("unzip "+path+places+".zip -d #{path}")
#    if File.exist?(countries)
      open(path+countries).each do |line|
        next if line =~ /^#/
        row = line.split("\t")
        options = {:code => row[0], :name => row[4]}
        country = GeoCountry.find_by_code(row[0])
        if country.nil?
          STDERR.puts "Adding new country #{row[4]}"
          GeoCountry.create!(options)
        else 
          STDERR.puts "Updating country #{country.name}"
          country.update_attributes(options)
        end
      end
#    end
#    if File.exist?(admin_codes)
      open(path+admin_codes).each do |line|
        row = line.split("\t")
        subrow = row[0].split(".")
        row[1].sub!(/^(.*\S)\s*$/, '\1')
        row[1] = subrow[1] if row[1] !~ /\S/## use the code if the name is blank
        geocountry = GeoCountry.find_by_code(subrow[0])
        options = {:geo_country_id => geocountry.id, :admin1_code => subrow[1], :name => row[1]}
        geoadmincode = geocountry.geo_admin_codes.find_by_admin1_code(subrow[1])
        if geoadmincode.nil? 
          STDERR.puts "Adding new admin code #{subrow[1]}"
          GeoAdminCode.create!(options)
        else
          STDERR.puts "Updateing admin code #{geoadmincode.admin1_code}"
          geoadmincode.update_attributes(options)
        end
      end
      ## make records for 'Country (general)' if they're not there 
      GeoCountry.find(:all).each do |gc|
        next if gc.geo_admin_codes.find_by_admin1_code('00')
        GeoAdminCode.create!(:geo_country_id => gc.id, :admin1_code => '00', :name => "#{gc.name} (general)")
      end
#    end 
#    if File.exist?(places+".txt")
      open(path+places+".txt").each do |line|
        row = line.split("\t")
        geocountry = GeoCountry.find_by_code(row[8])
        row[10] = '00' if row[10] !~ /\S/ 
        STDERR.puts "on #{row[0]} :: #{row[10].to_s} :: #{row[8]}"
        geoadmincode = geocountry.geo_admin_codes.find_by_admin1_code(row[10])
        # if there is no admin code matching the record, use the general admin code
        geoadmincode ||= geocountry.geo_admin_codes.find_by_admin1_code('00')
        row[3].sub!(/^(.*\S)\s*$/,'\1')
        options = {
          :geo_country_id => geoadmincode.geo_country_id,
          :geo_admin_code_id => geoadmincode.id,
          :geonameid => row[0],
          :name => row[1],
          :alternatenames => row[3],
          :latitude => row[4],
          :longitude => row[5]
        }
        geoplace = geoadmincode.geo_places.find_by_geonameid(row[0])
        if geoplace.nil? 
          STDERR.puts "Adding new place #{row[1]}"
          GeoPlace.create!(options)
        else
          STDERR.puts "Updating place #{row[1]}"
          geoplace.update_attributes(options)
        end
      end
#    end
#    zipped.each do |file|
#      system("gzip #{file}") if File.exist?(file)
#    end
  end

end


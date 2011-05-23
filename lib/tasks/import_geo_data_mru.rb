namespace :cg do

  desc "Imports GeoNames files containing geographic data into models."
  task :import_geo_data_mru => :environment do
#    require 'net/http'
    all_data_countries = ['LR', 'SL', 'GN', 'CI']
    # see http://www.geonames.org/export/codes.html
    all_data_feature_classes = ['A','P']
    path = "#{RAILS_ROOT}/tmp/geo_data"
    uri = "/export/dump"
    countries = "/countryInfo.txt"
    admin_codes = "/admin1Codes.txt"
    places = "/allCountries"
    Dir.mkdir(path) if ! File.directory?(path)
#    [countries, admin_codes, places+".zip"].each do |geofile|
#      Net::HTTP.start("download.geonames.org") { |http|
#        resp = http.get(uri+geofile)
#        open(path+geofile, "w") { |file|
#          file.write(resp.body)
#        }
#      }
#    end
#    system("unzip "+path+places+".zip -d #{path}")
      open(path+places+".txt").each do |line|
        row = line.split("\t")
        # include places with populations less than 1000 if they are one of the MRU countries
        if all_data_countries.include?(row[8])
          next if !all_data_feature_classes.include?(row[6])
        else
          next if row[14].to_i < 1000
        end
        geocountry = GeoCountry.find_by_code(row[8])
        next if geocountry.nil?
        row[10] = '00' if row[10] !~ /\S/
        STDERR.puts "on #{row[0]} :: #{row[10].to_s} :: #{row[8]} :: #{row[14]}"
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
          :longitude => row[5],
          :population => row[14].to_i
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
  end

end


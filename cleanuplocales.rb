$KCODE="UTF8"
require 'pp'
require 'yaml'
$: << 'vendor/plugins/ya2yaml/lib'
require 'vendor/plugins/ya2yaml/init.rb'

weymls = Dir.glob("lang/*.yml")
alldata = YAML::load_file("config/locales/en.yml")["en"]
allkeys = alldata.keys

count = 0
weymls.each do |weyml|
  locale = weyml.gsub("lang/", "")[0,2]
  puts "------------"
  puts locale
  data = YAML::load_file(weyml)
  begin
    muniadata = YAML::load_file("config/locales/#{locale}.yml")[locale]
  rescue
    muniadata = {}
  end

  # downcase keys and only keep ones that are canonical
  wekeys = data.each do |k, t|
    if allkeys.include?(k.downcase) and !muniadata.keys.include?(k.downcase)
      allt = alldata[k.downcase]
      allsubs = allt.scan(/\{\{(.*?)\}\}/).flatten.sort
      wesubs = t.scan(/\{(.*?)\}/).flatten.sort
      if allsubs != wesubs
        puts k.downcase
        puts "canonical: #{allsubs.inspect} -- #{allt}"
        puts "wern: #{wesubs.inspect} -- #{t}"
        puts
        count += 1
      else
        muniadata[k.downcase] = t
      end
    end
  end



  newdata = {locale => newdata}
  path = "mergedlocales/#{locale}.yml"
  File.open(path, 'w') {|f| f.write(newdata.ya2yaml) }
end
  puts count

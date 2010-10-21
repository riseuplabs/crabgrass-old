#
# this whole frozen gem thing is totally messed up in rails. the rails code
# seems super buggy around frozen gems. it dies if everything is not exactly as
# it expects.
#
# frozen gems only work if you run "rake gems:unpack" and the gems are installed
# on the system. But there are other cases where you want to freeze a gem in
# another way, and rails just doesn't allow it.
#
# this script attempts to rebuild the required .specification files regardless
# of where the gem in vendor/gems came from.
#

Dir.chdir( File.dirname(__FILE__) + '/gems' ) do |gemsdir|
  Dir.glob('*').each do |gem|
    Dir.chdir(gem) do |gemdir|
      puts
      puts gemdir
      if File.exists?('.specification')
        puts '  skipping, .specification already exists'
      elsif Dir.glob('*.gemspec').any?
        puts '  generating .specification'
        `gem build *.gemspec`
         if Dir.glob('*.gem').any?
          `gem specification *.gem > .specification`
          `rm *.gem`
         end
         if File.zero?('.specification')
           puts '  failed to create a .specification'
           `rm .specification`
         end
         # i don't understand gems, but sometimes the name in the gemspec
         # doesn't match what rails requires in the .specification.
         # ie: gemspec says 'greencloth', but rails requires 'riseuplabs-greencloth'
         gem_name = gemdir.sub(/-[\d\.]+$/,'')
         name_in_spec = `grep '^name:' .specification`.strip
         if "name: #{gem_name}" != name_in_spec
           `sed --in-place 's/^#{name_in_spec}/name: #{gem_name}/' .specification`
         end
      else
        puts '  no .gemspec and no .specification -- you are going to have to sort out the problem yourself.'
      end
    end
  end
end


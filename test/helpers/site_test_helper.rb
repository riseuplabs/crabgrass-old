module SiteTestHelper

  def self.included(base)
    base.instance_eval do
      # takes collections of sites and a block. runs all the tests defined in the block
      # for each site.
      # +sites+ is a hash, each key is a site name. values can be _true_, _false_ (don't test the site)
      # or a hash of site attributes to override
      #
      # Example:
      # with_site(:site1 => {:profiles => ['private']}, :site2 => true) {
      #   def test_something;
      #     assert_something
      #   end
      # }
      def self.repeat_with_sites(sites = {})
        return unless block_given?

        # yield will define some new methods, some of which are tests
        old_methods = self.instance_methods
        yield
        new_methods = self.instance_methods
        # methods defined in the yielded block that start with 'test'
        new_test_methods = (new_methods - old_methods).grep /^test/

        new_test_methods.each do |test_method_name|
          aliased_test_method_name = "do_#{test_method_name}".to_sym
          test_method_name = test_method_name.to_sym

          # alias do_test_something for test_something
          self.class_eval "alias :#{aliased_test_method_name} :#{test_method_name}"
          # delete test_something (so it's not get executed)
          self.class_eval "undef :#{test_method_name}"

          sites.keys.each do |site_name|
            site_attributes = sites[site_name]
            next unless site_attributes
            site_name = "nil" if site_name.nil?
            site_method_name = "#{test_method_name}_with_site_#{site_name}"

            define_method site_method_name do
              with_site(site_name, site_attributes) {send(aliased_test_method_name)}
            end
          end
        end
      end
    end
  end


  def disable_site_testing
    Conf.disable_site_testing
    Site.current = Site.new
    @controller.disable_current_site if @controller
  end

  def enable_site_testing(site_name=nil)
    if site_name
      site=Site.find_by_name(site_name.to_s) || sites(site_name.to_s)
      raise ActiveRecord::RecordNotFound.new("Failed to find site named #{site_name}. Available sites are: #{Site.all.map(&:name).join(', ')}") unless site
      Conf.enable_site_testing(site)
      Site.current = site
    else
      Conf.enable_site_testing()
      Site.current = Site.new
    end
    #raise "Something went terribly wrong: Site.current is not set, even though we just set it!" unless Site.current
    @controller.enable_current_site if @controller
    # Site.current seems to get confused in tests (but only in rails 2.3)
    return site
  end

  # run the block with a site
  def with_site(site_name, site_attributes = true)
    return unless block_given?

    old_enabled_site_ids = Conf.enabled_site_ids
    old_site = Site.current

    # set the site to the new one
    site = enable_site_testing(site_name)
    # override site options
    unmodified_site_attributes = site.attributes
    if site_attributes.respond_to? :each
      site_attributes.each {|attr, value| site.send("#{attr}=", value)}
      updated_site_attributes = true
      site.save!
    end

    # Run the block
    yield site
  ensure
    # restore
    if updated_site_attributes
      Site.current.attributes = unmodified_site_attributes
      Site.current.save!
    end
    disable_site_testing
    Conf.enabled_site_ids = old_enabled_site_ids
    Site.current = old_site
  end

  def enable_unlimited_site_testing(site_name=nil)
    if block_given?
      enable_site_testing(site_name, false) do
        yield
      end
    else
      enable_site_testing(site_name, false)
    end
  end
end

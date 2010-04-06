
module ActsAsSiteLimited
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def acts_as_site_limited()
      belongs_to :site
      before_save :update_site_id
      class_eval do

        ##
        ## CALLBACK
        ##

        def update_site_id
          if self.site_id.nil? and Site.current and Site.current.id
            self.site_id = Site.current.id
          end
        end

        ##
        ## OVERRIDE FINDERS
        ##

        def self.find_every(*args)
          super(*prepare_site_limited_options(*args))
        end
        def self.count(*args)
          # patch the sql statement to avoid things like
          # count (pages*)
          if args[0] && args[0].is_a?(Hash) && args[0][:select]
            args[0][:select].gsub!(/(.*\.)/i,'')
          end
          super(*prepare_site_limited_options(*args))
        end

        def self.find_by_sql(sql)
          super(prepare_site_limited_sql(sql))
        end
        def self.count_by_sql(sql)
          super(prepare_site_limited_sql(sql))
        end

        private

        ##
        ## LIMIT THE QUERIES
        ##

        # allows the use of special macro /*SITE_LIMITED*/ for :finder_sql
        def self.prepare_site_limited_sql(sql)
          sub_site = "1"
          if Site.current and Site.current.limited?
            sub_site = "site_id = #{Site.current.id}"
          end

          if sql.is_a? Array
            # [SELECT x FROM y WHERE z = ?, real_z]
            return sql.first.sub('/*SITE_LIMITED*/', sub_site)
          else
            return sql.sub('/*SITE_LIMITED*/', sub_site)
          end
        end

        def self.prepare_site_limited_options(*args)
          if Site.current and Site.current.limited?
            options = args.last.is_a?(Hash) ? args.pop : {}
            sql = "site_id = #{Site.current.id}"
            if options[:conditions].nil?
              options[:conditions] = {:site_id => Site.current.id}
            elsif options[:conditions].is_a? Hash
              options[:conditions].merge!({:site_id => Site.current.id})
            elsif options[:conditions].is_a? String
              options[:conditions] = "(#{options[:conditions]}) AND #{sql}"
            elsif options[:conditions].is_a? Array and options[:conditions][0].is_a? String
              options[:conditions][0] = "(#{options[:conditions][0]}) AND #{sql}"
            end
            args << options
          end
          args
        end

      end
    end # end acts_as_site_limited

  end
end

#      extend Finders
#      include Callbacks

      #named_scope(:for_site, lambda do |site|
      #  site ||= Site.current
      #  if site and site.id and site.limited?
      #    {:conditions => ['site_id = ?', site.id]}
      #  else
      #    {}
      #  end
      #end)

#  module Callbacks
#    def update_site_id
#      if self.site_id.nil? and Site.current and Site.current.id
#        self.site_id = Site.current.id
#      end
#    end
#  end

#  module Finders
#    def find_every(*args)
#      super(*prepare_site_limited_options(*args))
#    end

#    def count(*args)
#      super(*prepare_site_limited_options(*args))
#    end

#    def prepare_site_limited_options(*args)
#      if Site.current and Site.current.limited?
#        options = args.last.is_a?(Hash) ? args.pop : {}
#        sql = "site_id = #{Site.current.id}"
#        if options[:conditions].nil?
#          options[:conditions] = {:site_id => Site.current.id}
#        elsif options[:conditions].is_a? Hash
#          options[:conditions].merge!({:site_id => Site.current.id})
#        else options[:conditions].is_a? String
#          options[:conditions] += " AND #{sql}"
#        end
#        args << options
#      end
#      args
#    end
#  end




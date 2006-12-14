require "date"

module ActionView
  module Helpers
    # The Date Helper primarily creates select/option tags for different kinds of dates and date elements. All of the select-type methods
    # share a number of common options that are as follows:
    #
    # * <tt>:prefix</tt> - overwrites the default prefix of "date" used for the select names. So specifying "birthday" would give
    #   birthday[month] instead of date[month] if passed to the select_month method.
    # * <tt>:include_blank</tt> - set to true if it should be possible to set an empty date.
    # * <tt>:discard_type</tt> - set to true if you want to discard the type part of the select name. If set to true, the select_month
    #   method would use simply "date" (which can be overwritten using <tt>:prefix</tt>) instead of "date[month]".
    module DateHelper # :nodoc:
      def distance_of_time_in_words(from_time, to_time = 0, include_seconds = false)
        from_time = from_time.to_time if from_time.respond_to?(:to_time)
        to_time = to_time.to_time if to_time.respond_to?(:to_time)
        distance_in_minutes = (((to_time - from_time).abs)/60).round
        distance_in_seconds = ((to_time - from_time).abs).round

        case distance_in_minutes
          when 0..1
            return (distance_in_minutes==0) ? 'less than a minute'.t : ('%d minutes' / 1) unless include_seconds
            case distance_in_seconds
              when 0..5   then 'less than %d seconds' / 5
              when 6..10  then 'less than %d seconds' / 10
              when 11..20 then 'less than %d seconds' / 20
              when 21..40 then 'half a minute'.t
              when 41..59 then 'less than a minute'.t
              else             '%d minutes' / 1
            end
                                
          when 2..45      then '%d minutes' / distance_in_minutes
          when 46..90     then 'about %d hours' / 1
          when 90..1440   then 'about %d hours' / (distance_in_minutes.to_f / 60.0).round
          when 1441..2880 then '%d days' / 1
          else                 '%d days' / (distance_in_minutes / 1440).round
        end
      end
            
      # Returns a select tag with options for each of the months January through December with the current month selected.
      # The month names are presented as keys (what's shown to the user) and the month numbers (1-12) are used as values
      # (what's submitted to the server). It's also possible to use month numbers for the presentation instead of names --
      # set the <tt>:use_month_numbers</tt> key in +options+ to true for this to happen. If you want both numbers and names,
      # set the <tt>:add_month_numbers</tt> key in +options+ to true. Examples:
      #
      #   select_month(Date.today)                             # Will use keys like "January", "March"
      #   select_month(Date.today, :use_month_numbers => true) # Will use keys like "1", "3"
      #   select_month(Date.today, :add_month_numbers => true) # Will use keys like "1 - January", "3 - March"
      #
      # Override the field name using the <tt>:field_name</tt> option, 'month' by default.
      #
      # If you would prefer to show month names as abbreviations, set the
      # <tt>:use_short_month</tt> key in +options+ to true.
      def select_month(date, options = {})
        month_options = []
        abbr = options[:use_short_month]
        abbr_key = abbr ? 'abbreviated month' : 'month'
        month_names = abbr ? Date::ABBR_MONTHNAMES : Date::MONTHNAMES

        1.upto(12) do |month_number|
          month_name = if options[:use_month_numbers]
            month_number
          elsif options[:add_month_numbers]
            month_name_text = month_names[month_number]
            month_number.to_s + ' - ' +  
              "#{month_name_text} [#{abbr_key}]".t(month_name_text)
          else
            month_name_text = month_names[month_number]
            "#{month_name_text} [#{abbr_key}]".t(month_name_text)          
          end

          month_options << ((date && (date.kind_of?(Fixnum) ? date : date.month) == month_number) ?
            %(<option value="#{month_number}" selected="selected">#{month_name}</option>\n) :
            %(<option value="#{month_number}">#{month_name}</option>\n)
          )
        end

        select_html(options[:field_name] || 'month', month_options, options[:prefix], options[:include_blank], options[:discard_type], options[:disabled], options[:id], options[:class])
      end

      def select_year(date, options = {})
        year_options = []
        y = date ? (date.kind_of?(Fixnum) ? (y = (date == 0) ? Date.today.year : date) : date.year) : Date.today.year

        start_year, end_year = (options[:start_year] || y-5), (options[:end_year] || y+5)
        step_val = start_year < end_year ? 1 : -1

        start_year.step(end_year, step_val) do |year|
          year_options << ((date && (date.kind_of?(Fixnum) ? date : date.year) == year) ?
            %(<option value="#{year}" selected="selected">#{year}</option>\n) :
            %(<option value="#{year}">#{year}</option>\n)
          )
        end

        select_html(options[:field_name] || 'year', year_options, options[:prefix], options[:include_blank], options[:discard_type], options[:disabled], options[:id], options[:class])
      end
      
      private
        def select_html(type, options, prefix = nil, include_blank = false, discard_type = false, disabled = false, id = nil, klass = nil)
          select_html  = %(<select name="#{prefix || DEFAULT_PREFIX})
          select_html << "[#{type}]" unless discard_type
          select_html << %(")
          select_html << %( disabled="disabled") if disabled
          select_html << %( id="#{id}") if id
          select_html << %( class="#{klass}") if klass
          select_html << %(>\n)
          select_html << %(<option value=""></option>\n) if include_blank
          select_html << options.to_s
          select_html << "</select>\n"
      end
    end

  end
end

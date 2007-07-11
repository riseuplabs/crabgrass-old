### backported from edge rails ###

module ActiveSupport #:nodoc:
  module CoreExtensions #:nodoc:
    module Time #:nodoc:
      module Behavior
        # Enable more predictable duck-typing on Time-like classes. See
        # Object#acts_like?.
        def acts_like_time?
          true
        end
      end
    end
  end
end

class Time#:nodoc:
  include ActiveSupport::CoreExtensions::Time::Behavior
end

module ActiveSupport #:nodoc:
  module CoreExtensions #:nodoc:
    module Date #:nodoc:
      module Behavior
        # Enable more predictable duck-typing on Date-like classes. See
        # Object#acts_like?.
        def acts_like_date?
          true
        end
      end
    end
  end
end

class Date#:nodoc:
  include ActiveSupport::CoreExtensions::Date::Behavior
end

class Object
  # A duck-type assistant method. For example, ActiveSupport extends Date
  # to define an acts_like_date? method, and extends Time to define
  # acts_like_time?. As a result, we can do "x.acts_like?(:time)" and
  # "x.acts_like?(:date)" to do duck-type-safe comparisons, since classes that
  # we want to act like Time simply need to define an acts_like_time? method.
  def acts_like?(duck)
    respond_to? "acts_like_#{duck}?"
  end
end

### tweaks to make it work ###

# one option (let's go with this one, cause it's less core invasive)
module QuotedTzTime
  def quoted_id
    "'#{ActiveRecord::Base.connection.quoted_date(self)}'"
  end
end
TzTime.send :include, QuotedTzTime

# another option, this one a little more 'edgy'
=begin
module ActiveRecord
  module ConnectionAdapters
    module Quoting
      def quote_with_tztime(value, column=nil)
        if value.acts_like?(:date)
          "'#{value.to_s}'"
        elsif value.acts_like?(:time)
          "'#{quoted_date(value)}'"
        else
          quote_without_tztime(value, column)
        end
      end
      alias_method_chain :quote, :tztime
    end
  end
end
=end

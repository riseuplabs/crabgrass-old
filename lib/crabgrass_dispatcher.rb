
module CrabgrassDispatcher
  module Validations
    def self.included(base)
      base.extend ClassMethods
    end
    module ClassMethods
      # validates_handle makes sure that 
      # (1) the handle is in a good format
      # (2) the handle is not taken by an existing group or user
      # (3) the handle does not collide with our routes or controllers
      # 
      def validates_handle(*attr_names)
        configuration = { :message => ActiveRecord::Errors.default_error_messages[:invalid], :on => :save, :with => nil }
        configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

        validates_each(attr_names, configuration) do |record, attr_name, value|
          unless value
            record.errors.add(attr_name, 'must exist')
            next #can't use return cause it raises a LocalJumpError
          end
          unless (3..50).include? value.length
            record.errors.add(attr_name, 'must be at least 3 and no more than 50 characters')
          end
          unless /^[a-z0-9]+([-\+_]*[a-z0-9]+){1,49}$/ =~ value
            record.errors.add(attr_name, 'may only contain letters, numbers, underscores, and hyphens')
          end
          unless record.instance_of?(Committee)
            # only allow '+' for Committees
            if /\+/ =~ value
              record.errors.add(attr_name, 'may only contain letters, numbers, underscores, and hyphens')
            end
          end
          if value =~ /^(groups|me|people|networks|places|avatars|page|pages|account|static|places|assets|files|chat)$/
            record.errors.add(attr_name, 'is already taken')
          end
          # TODO: make this dynamic so this function can be
          # used over any set of classes (instead of just User, Group)
          if record.instance_of? User
            if User.exists?(['login = ? and id <> ?', value, record.id||-1])
              record.errors.add(attr_name, 'is already taken')
            end
            if Group.exists?({:name => value})
              record.errors.add(attr_name, 'is already taken')
            end
          elsif record.instance_of? Group
            if Group.exists?(['name = ? and id <> ?', value, record.id||-1])
              record.errors.add(attr_name, 'is already taken')
            end
            if User.exists?({:login => value})
              record.errors.add(attr_name, 'is already taken')
            end
          end
        end
      end
    end   
  end
end

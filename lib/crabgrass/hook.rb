# Inspired by:
#   Redmine - project management software
#   Copyright (C) 2006-2008  Jean-Philippe Lang
#   License: GPL v2 or later

module Crabgrass
  module Hook
    @@listener_classes = []
    @@listeners = nil
    @@hook_listeners = {}
    
    class << self
      # Adds a listener class.
      # Automatically called when a class inherits from Redmine::Hook::Listener.
      def add_listener(klass)
        raise "Hooks must include Singleton module." unless klass.included_modules.include?(Singleton)
        @@listener_classes << klass
        clear_listeners_instances
      end
      
      # Returns all the listerners instances.
      def listeners
        @@listeners ||= @@listener_classes.collect {|listener| listener.instance}
      end
 
      # Returns the listeners instances for the given hook.
      def hook_listeners(hook)
        @@hook_listeners[hook] ||= listeners.select {|listener| listener.respond_to?(hook)}
      end
      
      # Clears all the listeners.
      def clear_listeners
        @@listener_classes = []
        clear_listeners_instances
      end
      
      # Clears all the listeners instances.
      def clear_listeners_instances
        @@listeners = nil
        @@hook_listeners = {}
      end
      
      # Calls a hook.
      # Returns the listeners response.
      def call_hook(hook, context={})
        response = []
        hook_listeners(hook).each do |listener|
          listener.delegate_to(context[:delegate_to]) if context[:delegate_to]
          response << listener.send(hook, context).to_s
        end
        response.join("\n")
      end
    end

    # Base class for hook listeners.
    class Listener
      include Singleton

      def delegate_to(object)
        @delegator = object
      end
      def method_missing(method, *args)
        if @delegator
          @delegator.send(method, *args)
        else
          super(method, *args)
        end
      end

      # Registers the listener
      def self.inherited(child)
        Crabgrass::Hook.add_listener(child)
        super
      end
    end
    
    class ViewListener < Listener
    end

    # Helper module included in ApplicationHelper so that hooks can be called
    # in views like this:
    #   <%= call_hook(:some_hook) %>
    #   <%= call_hook(:another_hook, :foo => 'bar' %>
    # 
    # Current project is automatically added to the call context.
    module Helper
      def call_hook(hook, context={})
        defaults = {:page => @page, :user => @user, :group => @group, :delegate_to => self, :session => session}
        Crabgrass::Hook.call_hook(hook, defaults.merge(context))
      end
    end
  end
end

# this is done in an initializer instead:
#ApplicationHelper.send(:include, Crabgrass::Hook::Helper)

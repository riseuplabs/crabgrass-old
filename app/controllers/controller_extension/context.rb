##
## SETTING THE CONTEXT
##

#
# We use a plugin called 'before_render' which adds a special callback event.
#
# The before_render event is triggered after all the before_filters, but right
# before rendering starts. 
#
# This is a very useful time to set up variables needed for the view, based on
# whatever stuff the controller has been doing.
#

module ControllerExtension::Context

  private

  #
  # A special 'before_render' filter that calls 'context()' if this is a normal
  # request for html and there has not been a redirection. This allows
  # subclasses to put their navigation setup calls in context() because
  # it will only get called when appropriate.
  #
  def context_if_appropriate
    if !@skip_context and normal_request?
      @skip_context = true
      context()
      navigation()
    end
    true
  end

  protected

  #
  # a "before_render" filter that may be overridden by controllers.
  #
  # context() is called right before rendering starts (by the filter method
  # context_if_appropriate). in this method, the controller should set the
  # @context variable
  #
  def context
    @context = nil
  end

  #
  # sets up the navigation variables from the current theme.
  # The 'active' blocks of the navigation definition are evaluated in this
  # method, so any variables needed by those blocks must be set up before this
  # is called.
  #
  # I don't see any reason why a controller would want to override this, but they
  # could if they really wanted to.
  #
  def navigation
    current_theme.navigation.controller = self
    @global_navigation  = current_theme.navigation.root
    @context_navigation = @global_navigation.currently_active_item  if @global_navigation
    @local_navigation   = @context_navigation.currently_active_item if @context_navigation
  end

end

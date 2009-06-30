require 'thinking_sphinx'

if Rails::VERSION::STRING.to_f < 2.1
  ThinkingSphinx::Configuration.instance.load_models
end

if Rails::VERSION::STRING.to_f > 1.2
  require 'action_controller/dispatcher'

  ActionController::Dispatcher.to_prepare :thinking_sphinx do
    # CRABGRASS: Crabgrass hack - we don't need to load models for TS to work
    # loading them gives warnings
    # commented out load_models
    # ThinkingSphinx::Configuration.instance.load_models
  end
end
require 'thinking_sphinx'
require 'riddle'

ActiveRecord::Base.send(:include, ThinkingSphinx::ActiveRecord)

class NamespacedModelsMigration < ActiveRecord::Migration
  class << self
    def up
      ActiveRecord::Base.transaction do
        # Migrate any nested STI models
        nested_sti_models.each do |model|
          model.superclass.update_all "#{model.inheritance_column} = '#{model.name}'", "#{model.inheritance_column} = '#{model.name.demodulize}'"
        end
        
        # Migrate any polymorphic relationships
        polymorphic_reflections.each do |reflection|
          reflection.class_name.constantize.update_all "#{reflection.options[:as]}_type = '#{reflection.active_record.name}'", "#{reflection.options[:as]}_type = '#{reflection.active_record.name.demodulize}'"
        end
      end
    end
    
    def down
      ActiveRecord::Base.transaction do
        nested_sti_models.each do |model|
          model.superclass.update_all "#{model.inheritance_column} = '#{model.name.demodulize}'", "#{model.inheritance_column} = '#{model.name}'"
        end
        
        polymorphic_reflections.each do |reflection|
          reflection.class_name.constantize.update_all "#{reflection.options[:as]}_type = '#{reflection.active_record.name.demodulize}'", "#{reflection.options[:as]}_type = '#{reflection.active_record.name}'"
        end
      end
    end
    
    def nested_sti_models
      models.reject(&:descends_from_active_record?).reject { |m| m.parent == Object }
    end
    
    def polymorphic_reflections
      models.map { |m| m.reflections.values }.flatten.select { |r| r.options[:as] }
    end
    
    def models
      return @all_models if @all_models
      
      Dir[RAILS_ROOT + '/app/models/**/*.rb'].each { |f| require_dependency f }
      @all_models = Object.subclasses_of(ActiveRecord::Base)
    end
  end
end

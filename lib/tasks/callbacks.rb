# eg list_callbacks(Page, :before_save)
def print_callbacks(model, callback)
  model.send("#{callback}_callback_chain").each do |cb|
    unless STANDARD_CALLBACKS[callback].include?(cb.method)
      puts "    #{cb.method}"
    end
  end
end


desc "prints a list of models and their callbacks"
task(:callbacks => :environment) do

  AR_CALLBACKS = [:before_validation, :before_validation_on_create, :after_validation,
    :after_validation_on_create, :before_save, :before_create, :after_create, :after_save]

  STANDARD_CALLBACKS = Hash[AR_CALLBACKS.collect do |callback|
    methods = ActiveRecord::Base.send("#{callback}_callback_chain").collect{|cb|cb.method}
    [callback, methods]
  end]

  [Page,User,Group].each do |model|
    puts '='*80
    puts model.name

    AR_CALLBACKS.each do |callback|
      puts "  #{callback}"
      print_callbacks(model, callback)
    end
  end
end



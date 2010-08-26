module AfterCommit
  module ActiveRecord
    def self.included(base)
      base.class_eval do
        class << self
          def establish_connection_with_after_commit(spec = nil)
            result = establish_connection_without_after_commit spec
            include_after_commit_extensions
            result
          end
          alias_method_chain :establish_connection, :after_commit
          
          def include_after_commit_extensions
            base = ::ActiveRecord::ConnectionAdapters::AbstractAdapter
            Object.subclasses_of(base).each do |klass|
              include_after_commit_extension klass
            end
            
            if defined?(JRUBY_VERSION) and defined?(JdbcSpec::MySQL)
              include_after_commit_extension JdbcSpec::MySQL
            end
          end
          
          private
          
          def include_after_commit_extension(adapter)
            additions = AfterCommit::ConnectionAdapters
            unless adapter.included_modules.include?(additions)
              adapter.send :include, additions
            end
          end
        end
        
        define_callbacks  :after_commit,
                          :after_commit_on_create,
                          :after_commit_on_update,
                          :after_commit_on_save,
                          :after_commit_on_destroy,
                          :after_rollback,
                          :before_commit,
                          :before_commit_on_create,
                          :before_commit_on_update,
                          :before_commit_on_save,
                          :before_commit_on_destroy,
                          :before_rollback
        
        after_create  :add_committed_record_on_create
        after_update  :add_committed_record_on_update
        after_save    :add_committed_record_on_save
        after_destroy :add_committed_record_on_destroy
        
        def add_committed_record
          if have_callback? :before_commit, :after_commit, :before_rollback, :after_rollback
            AfterCommit.record(self.class.connection, self)
          end
        end
        
        def add_committed_record_on_create
          add_committed_record
          if have_callback? :before_commit_on_create, :after_commit_on_create
            AfterCommit.record_created(self.class.connection, self)
          end
        end
        
        def add_committed_record_on_update
          add_committed_record
          if have_callback? :before_commit_on_update, :after_commit_on_update
            AfterCommit.record_updated(self.class.connection, self)
          end
        end
        
        def add_committed_record_on_save
          if have_callback? :before_commit_on_save, :after_commit_on_save
            AfterCommit.record_saved(self.class.connection, self)
          end
        end
        
        def add_committed_record_on_destroy
          add_committed_record
          if have_callback? :before_commit_on_destroy, :after_commit_on_destroy
            AfterCommit.record_destroyed(self.class.connection, self)
          end
        end
      end
    end
  end
end

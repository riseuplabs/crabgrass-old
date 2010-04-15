module SkipTestHelper

  def self.included(base)
    base.class_eval do
      def self.skip_if(method_name)
        @skip_method = method_name || :skip?

        self.class_eval do
          def self.skip_method
            @skip_method
          end

          def run_with_skip(result, &block)
            run_without_skip(result, &block) unless send self.class.skip_method
          end

          alias_method_chain :run, :skip
        end
      end
    end
  end
end


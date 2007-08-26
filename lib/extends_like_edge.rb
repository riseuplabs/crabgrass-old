#
# stuff that is fixed in edge but not in stable, but that we cannot live without.
# so, we attempt to make it work here.
#


###################################################
# make association callbacks actually work with create()
#
# here is a patch to do it in edge, but stable is too different:
# http://dev.rubyonrails.org/ticket/8854
# http://dev.rubyonrails.org/attachment/ticket/8854/improve_add_callbacks_for_collections.patch
#

module ActiveRecord
  module Associations
    class AssociationCollection < AssociationProxy

      # added calls to callback()
      def create(attributes = {})
        if attributes.is_a?(Array)
          attributes.collect { |attr| create(attr) }
        else
          record = build(attributes)
          unless @owner.new_record?
            #puts 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
            callback(:before_add, record)
            #y callbacks_for(:after_add)
            #y @owner
            record.save
            #puts 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
            callback(:after_add, record)
          end
          record
        end
      end

    end
  end
end


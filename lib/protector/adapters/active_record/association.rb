module Protector
  module Adapters
    module ActiveRecord
      # Patches `ActiveRecord::Associations::SingularAssociation` and `ActiveRecord::Associations::CollectionAssociation`
      module Association
        extend ActiveSupport::Concern

        included do
          include Protector::DSL::Base

          # AR 4 has renamed `scoped` to `scope`
          if method_defined?(:scope)
            alias_method 'scope_without_protector', 'scope'
            alias_method 'scope', 'scope_with_protector'
          else
            alias_method 'scope_without_protector', 'scoped'
            alias_method 'scoped', 'scope_with_protector'
          end

          alias_method 'build_record_without_protector', 'build_record'
          alias_method 'build_record', 'build_record_with_protector'
        end

        # Wraps every association with current subject
        def scope_with_protector(*args)
          scope = scope_without_protector(*args)
          scope = scope.restrict!(protector_subject) if protector_subject?
          scope
        end

        # Forwards protection subject to the new instance
        def build_record_with_protector(*args)
          return build_record_without_protector(*args) unless protector_subject?
          build_record_without_protector(*args).restrict!(protector_subject)
        end

        # AR 4.2 hack - Disable skip_statement_cache?
        #
        # AR will only ask for scoping if skip_statement_cache? = true
        # skip_statement_cache? will only return true if there is a scope
        #
        # So we're it will never call the protect block to get the scope
        #def skip_statement_cache?
        #  return super unless protector_subject?

        #  true
        #end
      end
    end
  end
end

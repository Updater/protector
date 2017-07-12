module Protector
  module Adapters
    module ActiveRecord
      # Patches `ActiveRecord::Associations::Preloader`
      module Preloader extend ActiveSupport::Concern

        # Patches `ActiveRecord::Associations::Preloader::Association`
        module Association extend ActiveSupport::Concern
          included do
            # AR 4 has renamed `scoped` to `scope`
            if method_defined?(:scope)
              alias_method 'scope_without_protector', 'scope'
              alias_method 'scope', 'scope_with_protector'
            else
              alias_method 'scope_without_protector', 'scoped'
              alias_method 'scoped', 'scope_with_protector'
            end
          end

          # def

          # Gets current subject of preloading association
          def protector_subject
            # Owners are always loaded from the single source
            # having same protector_subject
            owners.first.protector_subject
          end

          def protector_subject?
            owners.first.protector_subject?
          end

          # Restricts preloading association scope with subject of the owner
          def scope_with_protector(*args)
            return scope_without_protector unless protector_subject?

            @meta ||= klass.protector_meta.evaluate(protector_subject)
            # binding.pry
            scope_without_protector.merge(@meta.relation).restrict!(protector_subject)
          end

          # def scope_with_protector(*args)
          #   scope = scope_without_protector(*args)
          #   scope = scope.restrict!(protector_subject) if protector_subject?
          #   scope
          # end
        end
      end
    end
  end
end

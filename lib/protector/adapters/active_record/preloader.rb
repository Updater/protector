module Protector
  module Adapters
    module ActiveRecord
      # Patches `ActiveRecord::Associations::Preloader`
      module Preloader extend ActiveSupport::Concern

        # Patches `ActiveRecord::Associations::Preloader::Association`
        module Association extend ActiveSupport::Concern
          included do
            alias_method :scope_without_protector, :scope
            alias_method :scope, :scope_with_protector
          end

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

            scope_without_protector.merge(@meta.relation).restrict!(protector_subject)
          end
        end
      end
    end
  end
end

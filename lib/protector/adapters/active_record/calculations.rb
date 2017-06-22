module Protector
  module Adapters
    module ActiveRecord
      # Patches `ActiveRecord::Calculations`
      module Calculations

        # @note This is here cause `NullRelation` can return `nil` from `count`
        def count(*args)
          super || 0
        end

        # @note This is here cause `NullRelation` can return `nil` from `sum`
        def sum(*args)
          super || 0
        end

        # Merges current relation with restriction and calls real `calculate`
        def calculate(*args)
          return super unless protector_subject?
          protector_relation.unrestrict!.calculate(*args)
        end
      end
    end
  end
end

module Protector
  module Adapters
    module ActiveRecord
      # Patches `ActiveRecord::Associations::CollectionProxy`
      module CollectionProxy
        extend ActiveSupport::Concern
        delegate :protector_subject, :protector_subject?, :to => :@association

        def protector_relation
          result = super
          result.instance_variable_set(:@association, self.instance_variable_get(:@association).clone)
          result
        end

        def restrict!(*args)
          # binding.pry
          @association.restrict!(*args)
          super
        end

        def unrestrict!
          @association.unrestrict!
          super
        end
      end
    end
  end
end

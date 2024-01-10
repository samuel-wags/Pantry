# typed: strict
# frozen_string_literal: true

module DataLoader
  class BaseSerializable
    extend T::Sig

    class << self
      extend T::Sig

      sig { returns T::Array[Symbol] }
      def fields
        @fields ||= T.let([:id], T.nilable(T::Array[Symbol]))
      end

      sig { params(field_name: Symbol).void }
      def field(field_name)
        fields << field_name
      end
    end

    sig { params(model_instance: ApplicationRecord).void }
    def initialize(model_instance)
      self.class.fields.each do |field|
        var_name = "@#{field}"
        instance_variable_set(var_name, model_instance.send(field))
        define_singleton_method(field) { instance_variable_get(var_name) }
      end
    end
  end
end

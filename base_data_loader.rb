# typed: strict
# frozen_string_literal: true

module DataLoader
  class BaseDataLoader
    extend T::Sig

    class << self
      extend T::Sig

      sig { returns Types::Schema }
      def schema
        @schema ||= T.let({}, T.nilable(Types::Schema))
      end

      private

      sig do
        params(
          table_name: Symbol,
          serializable: T.class_of(BaseSerializable),
          indexes: T::Array[Symbol]
        ).void
      end
      def table(table_name, serializable, indexes: [])
        define_method(table_name) { send(:registry).get(table_name) }
        define_method("load_#{table_name}") { |relation| send(:load, table_name, relation) }
        schema.store(
          table_name,
          TableSchema.new(
            {
              serializable:,
              indexes:
            }
          )
        )
      end
    end

    sig { returns Registry[LoaderTable[BaseSerializable]] }
    def registry
      @registry ||= T.let(Registry.new, T.nilable(Registry[LoaderTable[BaseSerializable]]))
    end

    sig { void }
    def initialize
      self.class.schema.each_pair do |key, table_schema|
        registry.add(
          key,
          LoaderTable.new(
            table_schema.serializable,
            table_schema.indexes
          )
        )
      end
    end

    sig { params(table_name: Symbol, relation: ActiveRecord::Relation).void }
    def load(table_name, relation)
      registry.get(table_name)&.load_relation(relation)
    end
  end
end

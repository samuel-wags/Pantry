# typed: strict
# frozen_string_literal: true

module DataLoader
  class LoaderTable
    extend T::Sig
    extend T::Generic

    Serializable = type_member { { upper: BaseSerializable } }

    sig do
      params(
        serializer_class: T::Class[Serializable],
        indexes: T::Array[Symbol]
      ).void
    end
    def initialize(serializer_class, indexes)
      @serializer_class = serializer_class
      @indexes = indexes
    end

    sig { params(relation: ActiveRecord::Relation).void }
    def load_relation(relation)
      relation.each { |record| load_model_instance(record) }
    end

    sig { returns(T::Array[Serializable]) }
    def all
      data.values
    end

    sig { params(props: T::Hash[Symbol, T.any(String, Integer, Float)]).returns T::Array[Serializable] }
    def where(props)
      index_props = props.each_pair.filter { |key, _| @indexes.include?(key) }
      # TODO: faster way to do this that doesn't iterate 4 times
      index_matches = index_props.map { |key, value| indexes_data.get(key)&.get(value) }.compact.flatten.uniq
      initial_data = index_matches.count.zero? ?
        data.values :
        # Sorbet doesn't currently support splats for rest parameters
        # https://sorbet.org/docs/error-reference#7019
        # T.unsafe allows us to spread the array
        T.unsafe(data).fetch_values(*index_matches)

      initial_data.filter do |item|
        props.each_pair.all? do |key, value|
          item.send(key) == value
        end
      end
    end

    private

    sig { returns T::Hash[String, Serializable] }
    def data
      @data ||= T.let({}, T.nilable(T::Hash[String, Serializable]))
    end

    sig { returns Registry[Registry[T::Array[String]]] }
    def indexes_data
      @indexes_data ||= T.let(
        Registry.new(@indexes.index_with { Registry.new }),
        T.nilable(Registry[Registry[T::Array[String]]])
      )
    end

    sig { params(model_instance: ApplicationRecord).void }
    def load_model_instance(model_instance)
      register(@serializer_class.new(model_instance))
    end

    sig { params(id: String).returns(T.nilable(Serializable)) }
    def get(id)
      data[id]
    end

    sig { params(serialized_item: Serializable).void }
    def register(serialized_item)
      id = serialized_item.id
      data[id] = serialized_item
      @indexes.each do |index|
        value = serialized_item.send(index)
        index_data = indexes_data.get(index)
        next if index_data.blank?

        existing_ids = index_data.get(value)
        if existing_ids.present?
          existing_ids.push id
        else
          index_data.add(value, [id])
        end
      end
    end
  end
end

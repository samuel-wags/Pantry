# typed: strict
# frozen_string_literal: true

module DataLoader
  class TableSchema < T::Struct
    prop :serializable, T::Class[BaseSerializable]
    prop :indexes, T::Array[Symbol]
  end
end

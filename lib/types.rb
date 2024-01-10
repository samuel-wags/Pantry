# frozen_string_literal: true
# typed: true

module DataLoader
  module Types
    Schema = T.type_alias { T::Hash[Symbol, TableSchema] }
  end
end

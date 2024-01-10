# frozen_string_literal: true
# typed: true

module DataLoader
  module TestClasses
    class TestLoader < BaseDataLoader
      table :assets, TestDataItem, indexes: %i[balance]
    end
  end
end

# typed: true
# frozen_string_literal: true

require 'test_helper'

class DataLoaderTest < ActiveSupport::TestCase
  describe 'When a BaseSerializable is created' do
    it 'stores fields properly' do
      assert_equal %i[id balance], DataLoader::TestClasses::TestDataItem.fields
    end
  end
  describe 'When a DataLoader is created' do
    it 'stores tables in schema' do
      assert_equal [:assets], DataLoader::TestClasses::TestLoader.schema.keys
    end

    it 'can load records' do
      create(:asset, balance: 100)
      create(:asset, balance: 100)

      loader = DataLoader::TestClasses::TestLoader.new

      assert_empty loader.assets.all

      loader.load_assets(Asset.all)

      assert_equal 2, loader.assets.all.count
    end

    it 'properly serializes records' do
      create(:asset, balance: 200)
      create(:asset, balance: 300)

      loader = DataLoader::TestClasses::TestLoader.new
      loader.load_assets(Asset.all)

      assert_equal 500, loader.assets.all.sum(&:balance)
    end

    it 'allows querying loaded records by property' do
      asset = create(:asset, balance: 200)
      asset = create(:asset, balance: 200)
      asset = create(:asset, balance: 300)

      loader = DataLoader::TestClasses::TestLoader.new
      loader.load_assets(Asset.all)

      assert_equal 2, loader.assets.where(balance: 200).count
      assert_equal 1, loader.assets.where(balance: 300).count
      assert_equal 0, loader.assets.where(balance: 100).count
    end
  end
end

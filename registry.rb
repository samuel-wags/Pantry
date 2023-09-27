# frozen_string_literal: true
# typed: true

module DataLoader
  class Registry
    extend T::Sig
    extend T::Generic

    Elem = type_member

    sig { params(initial_values: T.nilable(T::Hash[T.untyped, Elem])).void }
    def initialize(initial_values = nil)
      @registry = T.let(initial_values || {}, T::Hash[T.untyped, Elem])
    end

    sig do
      params(
        key: T.untyped,
        elem: Elem
      ).void
    end
    def add(
      key,
      elem
    )
      @registry[key] = elem
    end

    sig { params(key: T.untyped).returns(T.nilable(Elem)) }
    def get(key)
      @registry[key]
    end
  end
end

# typed: true
require 'parlour'

module Parlour
  module Types
    # Represents a method-scoped type variable, declared via a
    # solargraph-style `@generic` tag. Renders as `T.type_parameter(:name)`
    # for RBI, and as the bare variable name (which RBS expects to be bound
    # by an enclosing `[name] (...) -> ...` method signature) for RBS.
    class TypeParameter < Type
      sig { params(name: String).void }
      def initialize(name)
        @name = name
      end

      sig { returns(String) }
      attr_reader :name

      sig { params(other: Object).returns(T::Boolean) }
      def ==(other)
        TypeParameter === other && name == other.name
      end

      sig { override.returns(String) }
      def generate_rbi
        "T.type_parameter(:#{name})"
      end

      sig { override.returns(String) }
      def generate_rbs
        name
      end

      sig { override.returns(String) }
      def describe
        name
      end
    end
  end
end

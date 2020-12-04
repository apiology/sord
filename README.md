# Sord

## Overview

Sord is a [**So**rbet](https://sorbet.org) and [YA**RD**](https://yardoc.org/)
crossover. It can **automatically generate RBI and RBS type signature files** by
looking at the **types specified in YARD documentation** comments.

If your project is already YARD documented, then this can generate most of the
type signatures you need!

Sord is the perfect way to jump-start the adoption of types in your project,
whether you plan to use Sorbet's RBI format or Ruby 3/Steep's RBS format.

Sord has the following features:
  - Automatically generates signatures for modules, classes and methods
  - Support for multiple parameter or return types (`T.any`/`|`)
  - Gracefully handles missing YARD types (`T.untyped`/`untyped`)
  - Can infer setter parameter type from the corresponding getter's return type
  - Recognises mixins (`include` and `extend`)
  - Support for generic types such as `Array<T>` and `Hash<K, V>`
  - Can infer namespaced classes (`[Bar]` can become `GemName::Foo::Bar`)
  - Handles return types which can be `nil` (`T.nilable`/`untyped`)
  - Handles duck types (`T.untyped`/`untyped`)
  - Support for ordered list types (`[Array(Integer, Symbol)]` becomes `[Integer, Symbol]`)
  - Support for boolean types (`[true, false]` becomes `T::Boolean`/`bool`)
  - Support for `&block` parameters documented with `@yieldparam` and `@yieldreturn`

## Usage

Install Sord with `gem install sord`.

Sord is a command line tool. To use it, open a terminal in the root directory
of your project and invoke `sord`, passing a path where you'd like to save your
file (this file will be overwritten):

```
sord defs.rbi
```

Sord will generate YARD docs and then print information about what it's inferred
as it runs. It is best to fix any issues in the YARD documentation, as any edits
made to the resulting file will be replaced if you re-run Sord.

The output type is inferred by the file extension you use, but you can also
specify it explicitly with `--rbi` or `--rbs`.

## Shipping RBI Types

RBI files generated by Sord can be used in two main ways:

- [Shipped in the gem itself](https://sorbet.org/docs/rbi#rbis-within-gems).
- Contributed to [sorbet-typed](https://github.com/sorbet/sorbet-typed).

Generally, you should ship the type signatures with your gem if possible.
sorbet-typed is meant to be a place for gems that are no longer updated or
where the maintainer is unwilling to ship type signatures with the gem itself.

### Flags

Sord also takes some flags to alter the generated file:

  - `--rbi`/`--rbs`: Override the output format inferred from the file
    extension.
  - `--no-sord-comments`: Generates the file without any Sord comments about
    warnings/inferences/errors. (The original file's comments will still be
    included.)
  - `--no-regenerate`: By default, Sord will regenerate a repository's YARD
    docs for you. This option skips regenerating the YARD docs.
  - `--break-params`: Determines how many parameters are necessary before
    the signature is changed from a single-line to a multi-line block.
    (Default: 4)
  - `--replace-errors-with-untyped`: Uses `T.untyped` instead of `SORD_ERROR_*`
    constants.
  - `--replace-unresolved-with-untyped`: Uses `T.untyped` when Sord is unable to
    resolve a constant.
  - `--include-messages` and `--exclude-messages`: Used to filter the logging
    messages given by Sord. `--include-messages` acts as a whitelist, printing
    only messages of the specified logging kinds, whereas `--exclude-messages`
    acts as a blacklist and suppresses the specified logging kinds. Both flags
    take a comma-separated list of logging kinds, for example `omit,infer`.
    When using `--include-messages`, the `done` kind is included by default.
    (You cannot specify both `--include-messages` and `--exclude-messages`.)

## Example

Say we have this file, called `test.rb`:

```ruby
module Example
  class Person
    # @param name [String] The name of the Person to create.
    # @param age [Integer] The age of the Person to create.
    # @return [Example::Person]
    def initialize(name, age)
      @name = name
      @age = age
    end

    # @return [String]
    attr_accessor :name

    # @return [Integer]
    attr_accessor :age

    # @param possible_names [Array<String>] An array of potential names to choose from.
    # @param possible_ages [Array<Integer>] An array of potential ages to choose from.
    # @return [Example::Person]
    def self.construct_randomly(possible_names, possible_ages)
      Person.new(possible_names.sample, possible_ages.sample)
    end
  end
end
```

First, generate a YARD registry by running `yardoc test.rb`. Then, we can run
`sord test.rbi` to generate the RBI file. (Careful not to overwrite your code
files! Note the `.rbi` file extension.) In doing this, Sord prints:

```
[INFER] Assuming from filename you wish to generate in RBI format
[DONE ] Processed 8 objects (2 namespaces and 6 methods)
```

The `test.rbi` file then contains a complete RBI file for `test.rb`:

```ruby
# typed: strong
module Example
  class Person
    # _@param_ `name` — The name of the Person to create.
    # 
    # _@param_ `age` — The age of the Person to create.
    sig { params(name: String, age: Integer).void }
    def initialize(name, age); end

    # _@param_ `possible_names` — An array of potential names to choose from.
    # 
    # _@param_ `possible_ages` — An array of potential ages to choose from.
    sig { params(possible_names: T::Array[String], possible_ages: T::Array[Integer]).returns(Example::Person) }
    def self.construct_randomly(possible_names, possible_ages); end

    sig { returns(String) }
    attr_accessor :name

    sig { returns(Integer) }
    attr_accessor :age
  end
end
```

If we had instead generated `test.rbs`, we would get this file in RBS format:

```ruby
module Example
  class Person
    # _@param_ `name` — The name of the Person to create.
    # 
    # _@param_ `age` — The age of the Person to create.
    def initialize: (String name, Integer age) -> void

    # _@param_ `possible_names` — An array of potential names to choose from.
    # 
    # _@param_ `possible_ages` — An array of potential ages to choose from.
    def self.construct_randomly: (Array[String] possible_names, Array[Integer] possible_ages) -> Example::Person

    attr_accessor name: String

    attr_accessor age: Integer
  end
end
```

## Things to be aware of

The general rule of thumb for type conversions is:

  - If Sord understands the YARD type, then it is converted into the RBI or RBS
    type.
  - If the YARD type is missing, Sord fills in `T.untyped`.
  - If the YARD type can't be understood, Sord creates an undefined Ruby constant
    with a similar name to the unknown YARD type. For example, the obviously
    invalid YARD type `A%B` will become a constant called `SORD_ERROR_AB`.
    You should search through your resulting file to find and fix and 
    `SORD_ERROR`s.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/AaronC81/sord. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

While contributing, if you want to see the results of your changes to Sord you
can use the `examples:seed` Rake task. The task uses Sord to generate types for
a number of open source Ruby gems, including Bundler, Haml, Rouge, and RSpec.
`rake examples:seed` (and `rake examples:reseed` to regenerate the files) will
clone the repositories of these gems into `sord_examples/` and then generate the
files into the same directory.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Sord project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/AaronC81/sord/blob/master/CODE_OF_CONDUCT.md).

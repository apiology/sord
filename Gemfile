source "https://rubygems.org"

# Specify your gem's dependencies in sord.gemspec
gemspec

# TEMPORARY: pending https://github.com/AaronC81/parlour/pull/152 (adds
# Parlour::Types::TypeVariable) and https://github.com/AaronC81/parlour/pull/153
# (adds generic class/module support) being merged and released. Revert to the
# gemspec's published version constraint once those ship.
gem 'parlour', git: 'https://github.com/apiology/parlour', branch: 'add_class_generic_type_parameters'

# Not in gemspec so it doesn't get distributed or depended on by the built gem.
# Used by resolver tests, to ensure Sord can import bundled RBIs from gems.
gem 'resolver-test', path: 'spec/resolver-test-gem'

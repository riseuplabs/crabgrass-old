require File.expand_path(File.dirname(__FILE__) + '/../../../test/mod_test_helper')
Engines::Testing.set_fixture_path

class SuperAdmin < Mod
  # this is used for namespacing in the tests and storing information that is
  # relevant for the whole mod - such as migrations.
end

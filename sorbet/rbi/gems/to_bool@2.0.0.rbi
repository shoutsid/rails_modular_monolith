# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `to_bool` gem.
# Please instead update this file by running `bin/tapioca gem to_bool`.


# source://to_bool//lib/to_bool.rb#9
class Integer < ::Numeric
  # source://to_bool//lib/to_bool.rb#10
  def to_bool; end

  # source://to_bool//lib/to_bool.rb#10
  def to_boolean; end
end

Integer::GMP_VERSION = T.let(T.unsafe(nil), String)

# source://to_bool//lib/to_bool.rb#26
class Object < ::BasicObject
  include ::Kernel
  include ::PP::ObjectMixin

  # source://to_bool//lib/to_bool.rb#27
  def to_bool; end

  # source://to_bool//lib/to_bool.rb#27
  def to_boolean; end
end

# source://to_bool//lib/to_bool.rb#1
class String
  include ::Comparable

  # source://to_bool//lib/to_bool.rb#2
  def to_bool; end

  # source://to_bool//lib/to_bool.rb#2
  def to_boolean; end
end

# source://to_bool//lib/to_bool.rb#34
class Symbol
  include ::Comparable

  # source://to_bool//lib/to_bool.rb#35
  def to_bool; end

  # source://to_bool//lib/to_bool.rb#35
  def to_boolean; end
end

# source://to_bool//lib/to_bool.rb#18
class TrueClass
  # source://to_bool//lib/to_bool.rb#19
  def to_bool; end

  # source://to_bool//lib/to_bool.rb#19
  def to_boolean; end
end

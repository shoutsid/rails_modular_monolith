# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `patience_diff` gem.
# Please instead update this file by running `bin/tapioca gem patience_diff`.


# source://patience_diff//lib/patience_diff/formatting_context.rb#3
module PatienceDiff; end

# source://patience_diff//lib/patience_diff/differ.rb#6
class PatienceDiff::Differ
  # Options:
  #   * :all_context: Output the entirety of each file. This overrides the sequence matcher's context setting.
  #   * :line_ending: Delimiter to use when joining diff output. Defaults to $RS.
  #   * :ignore_whitespace: Before comparing lines, strip trailing whitespace, and treat leading whitespace
  #     as either present or not. Does not affect output.
  # Any additional options (e.g. :context) are passed on to the sequence matcher.
  #
  # @return [Differ] a new instance of Differ
  #
  # source://patience_diff//lib/patience_diff/differ.rb#16
  def initialize(opts = T.unsafe(nil)); end

  # Returns the value of attribute all_context.
  #
  # source://patience_diff//lib/patience_diff/differ.rb#8
  def all_context; end

  # Sets the attribute all_context
  #
  # @param value the value to set the attribute all_context to.
  #
  # source://patience_diff//lib/patience_diff/differ.rb#8
  def all_context=(_arg0); end

  # Generates a unified diff from the contents of the files at the paths specified.
  #
  # source://patience_diff//lib/patience_diff/differ.rb#24
  def diff_files(left_file, right_file, formatter = T.unsafe(nil)); end

  # Generate a unified diff of the data specified. The left and right values should be strings, or any other indexable, sortable data.
  # File names and timestamps do not affect the diff algorithm, but are used in the header text.
  #
  # source://patience_diff//lib/patience_diff/differ.rb#36
  def diff_sequences(left, right, left_name = T.unsafe(nil), right_name = T.unsafe(nil), left_timestamp = T.unsafe(nil), right_timestamp = T.unsafe(nil), formatter = T.unsafe(nil)); end

  # Returns the value of attribute ignore_whitespace.
  #
  # source://patience_diff//lib/patience_diff/differ.rb#8
  def ignore_whitespace; end

  # Sets the attribute ignore_whitespace
  #
  # @param value the value to set the attribute ignore_whitespace to.
  #
  # source://patience_diff//lib/patience_diff/differ.rb#8
  def ignore_whitespace=(_arg0); end

  # Returns the value of attribute line_ending.
  #
  # source://patience_diff//lib/patience_diff/differ.rb#8
  def line_ending; end

  # Sets the attribute line_ending
  #
  # @param value the value to set the attribute line_ending to.
  #
  # source://patience_diff//lib/patience_diff/differ.rb#8
  def line_ending=(_arg0); end

  # Returns the value of attribute matcher.
  #
  # source://patience_diff//lib/patience_diff/differ.rb#7
  def matcher; end
end

# Formats a plaintext unified diff.
#
# source://patience_diff//lib/patience_diff/formatter.rb#5
class PatienceDiff::Formatter
  # @return [Formatter] a new instance of Formatter
  #
  # source://patience_diff//lib/patience_diff/formatter.rb#9
  def initialize(differ, title = T.unsafe(nil)); end

  # @yield [context]
  #
  # source://patience_diff//lib/patience_diff/formatter.rb#15
  def format; end

  # Returns the value of attribute left_name.
  #
  # source://patience_diff//lib/patience_diff/formatter.rb#7
  def left_name; end

  # Sets the attribute left_name
  #
  # @param value the value to set the attribute left_name to.
  #
  # source://patience_diff//lib/patience_diff/formatter.rb#7
  def left_name=(_arg0); end

  # Returns the value of attribute left_timestamp.
  #
  # source://patience_diff//lib/patience_diff/formatter.rb#7
  def left_timestamp; end

  # Sets the attribute left_timestamp
  #
  # @param value the value to set the attribute left_timestamp to.
  #
  # source://patience_diff//lib/patience_diff/formatter.rb#7
  def left_timestamp=(_arg0); end

  # Returns the value of attribute names.
  #
  # source://patience_diff//lib/patience_diff/formatter.rb#6
  def names; end

  # source://patience_diff//lib/patience_diff/formatter.rb#21
  def render_header(left_name = T.unsafe(nil), right_name = T.unsafe(nil), left_timestamp = T.unsafe(nil), right_timestamp = T.unsafe(nil)); end

  # source://patience_diff//lib/patience_diff/formatter.rb#42
  def render_hunk(a, b, opcodes, last_line_shown); end

  # source://patience_diff//lib/patience_diff/formatter.rb#33
  def render_hunk_marker(opcodes); end

  # Returns the value of attribute right_name.
  #
  # source://patience_diff//lib/patience_diff/formatter.rb#7
  def right_name; end

  # Sets the attribute right_name
  #
  # @param value the value to set the attribute right_name to.
  #
  # source://patience_diff//lib/patience_diff/formatter.rb#7
  def right_name=(_arg0); end

  # Returns the value of attribute right_timestamp.
  #
  # source://patience_diff//lib/patience_diff/formatter.rb#7
  def right_timestamp; end

  # Sets the attribute right_timestamp
  #
  # @param value the value to set the attribute right_timestamp to.
  #
  # source://patience_diff//lib/patience_diff/formatter.rb#7
  def right_timestamp=(_arg0); end

  # Returns the value of attribute title.
  #
  # source://patience_diff//lib/patience_diff/formatter.rb#7
  def title; end

  # Sets the attribute title
  #
  # @param value the value to set the attribute title to.
  #
  # source://patience_diff//lib/patience_diff/formatter.rb#7
  def title=(_arg0); end

  private

  # source://patience_diff//lib/patience_diff/formatter.rb#58
  def left_header_line(name, timestamp); end

  # source://patience_diff//lib/patience_diff/formatter.rb#62
  def right_header_line(name, timestamp); end
end

# Delegate object yielded by the #format method.
#
# source://patience_diff//lib/patience_diff/formatting_context.rb#5
class PatienceDiff::FormattingContext
  # @return [FormattingContext] a new instance of FormattingContext
  #
  # source://patience_diff//lib/patience_diff/formatting_context.rb#6
  def initialize(differ, formatter); end

  # source://patience_diff//lib/patience_diff/formatting_context.rb#12
  def files(left_file, right_file); end

  # source://patience_diff//lib/patience_diff/formatting_context.rb#24
  def format; end

  # source://patience_diff//lib/patience_diff/formatting_context.rb#32
  def names; end

  # source://patience_diff//lib/patience_diff/formatting_context.rb#20
  def orphan(sequence, name = T.unsafe(nil), timestamp = T.unsafe(nil)); end

  # source://patience_diff//lib/patience_diff/formatting_context.rb#16
  def sequences(left, right, left_name = T.unsafe(nil), right_name = T.unsafe(nil), left_timestamp = T.unsafe(nil), right_timestamp = T.unsafe(nil)); end

  # source://patience_diff//lib/patience_diff/formatting_context.rb#28
  def title; end
end

# Matches indexed data (generally text) using the Patience diff algorithm.
#
# source://patience_diff//lib/patience_diff/sequence_matcher.rb#3
class PatienceDiff::SequenceMatcher
  # Options:
  #   * :context: number of lines of context to use when grouping
  #
  # @return [SequenceMatcher] a new instance of SequenceMatcher
  #
  # source://patience_diff//lib/patience_diff/sequence_matcher.rb#10
  def initialize(opts = T.unsafe(nil)); end

  # Returns the value of attribute context.
  #
  # source://patience_diff//lib/patience_diff/sequence_matcher.rb#4
  def context; end

  # Sets the attribute context
  #
  # @param value the value to set the attribute context to.
  #
  # source://patience_diff//lib/patience_diff/sequence_matcher.rb#4
  def context=(_arg0); end

  # Generate a diff of a and b, and return an array of opcodes describing that diff.
  # Each opcode represents a range in a and b that is either equal, only in a,
  # or only in b. Opcodes are 5-tuples, in the format:
  #   0: code
  #      A symbol indicating the diff operation. Can be :equal, :delete, or :insert.
  #   1: a_start
  #      Index in a where the range begins
  #   2: a_end
  #      Index in a where the range ends.
  #   3: b_start
  #      Index in b where the range begins
  #   4: b_end
  #      Index in b where the range ends.
  #
  # For :equal, (a_end - a_start) == (b_end - b_start).
  # For :delete, a_start == a_end.
  # For :insert, b_start == b_end.
  #
  # source://patience_diff//lib/patience_diff/sequence_matcher.rb#80
  def diff_opcodes(a, b); end

  # Generate a diff of a and b using #diff_opcodes, and split the opcode into groups
  # whenever an :equal range is encountered that is longer than @context * 2.
  # Returns an array of arrays of 5-tuples as described for #diff_opcodes.
  #
  # source://patience_diff//lib/patience_diff/sequence_matcher.rb#17
  def grouped_opcodes(a, b); end

  private

  # source://patience_diff//lib/patience_diff/sequence_matcher.rb#242
  def bisect(piles, target); end

  # source://patience_diff//lib/patience_diff/sequence_matcher.rb#158
  def collapse_matches(matches); end

  # source://patience_diff//lib/patience_diff/sequence_matcher.rb#177
  def longest_unique_subsequence(a, b); end

  # source://patience_diff//lib/patience_diff/sequence_matcher.rb#103
  def match(a, b); end

  # source://patience_diff//lib/patience_diff/sequence_matcher.rb#212
  def patience_sort(deck); end

  # source://patience_diff//lib/patience_diff/sequence_matcher.rb#111
  def recursively_match(a, b, a_lo, b_lo, a_hi, b_hi); end
end

# source://patience_diff//lib/patience_diff/sequence_matcher.rb#6
class PatienceDiff::SequenceMatcher::Card < ::Struct
  # Returns the value of attribute index
  #
  # @return [Object] the current value of index
  def index; end

  # Sets the attribute index
  #
  # @param value [Object] the value to set the attribute index to.
  # @return [Object] the newly set value
  def index=(_); end

  # Returns the value of attribute previous
  #
  # @return [Object] the current value of previous
  def previous; end

  # Sets the attribute previous
  #
  # @param value [Object] the value to set the attribute previous to.
  # @return [Object] the newly set value
  def previous=(_); end

  # Returns the value of attribute value
  #
  # @return [Object] the current value of value
  def value; end

  # Sets the attribute value
  #
  # @param value [Object] the value to set the attribute value to.
  # @return [Object] the newly set value
  def value=(_); end

  class << self
    def [](*_arg0); end
    def inspect; end
    def keyword_init?; end
    def members; end
    def new(*_arg0); end
  end
end

# source://patience_diff//lib/patience_diff.rb#11
PatienceDiff::TEMPLATE_PATH = T.let(T.unsafe(nil), Pathname)

# source://patience_diff//lib/patience_diff/usage_error.rb#2
class PatienceDiff::UsageError < ::StandardError; end

# source://patience_diff//lib/patience_diff.rb#10
PatienceDiff::VERSION = T.let(T.unsafe(nil), String)

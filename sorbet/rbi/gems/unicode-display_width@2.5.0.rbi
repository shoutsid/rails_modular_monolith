# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `unicode-display_width` gem.
# Please instead update this file by running `bin/tapioca gem unicode-display_width`.


# source://unicode-display_width//lib/unicode/display_width/constants.rb#3
module Unicode
  private

  def abbr_categories(_arg0); end
  def capitalize(_arg0); end
  def categories(_arg0); end
  def compose(_arg0); end
  def decompose(_arg0); end
  def decompose_compat(_arg0); end
  def decompose_safe(_arg0); end
  def downcase(_arg0); end
  def nfc(_arg0); end
  def nfc_safe(_arg0); end
  def nfd(_arg0); end
  def nfd_safe(_arg0); end
  def nfkc(_arg0); end
  def nfkd(_arg0); end
  def normalize_C(_arg0); end
  def normalize_C_safe(_arg0); end
  def normalize_D(_arg0); end
  def normalize_D_safe(_arg0); end
  def normalize_KC(_arg0); end
  def normalize_KD(_arg0); end
  def strcmp(_arg0, _arg1); end
  def strcmp_compat(_arg0, _arg1); end
  def text_elements(_arg0); end
  def upcase(_arg0); end
  def width(*_arg0); end

  class << self
    def abbr_categories(_arg0); end
    def capitalize(_arg0); end
    def categories(_arg0); end
    def compose(_arg0); end
    def decompose(_arg0); end
    def decompose_compat(_arg0); end
    def decompose_safe(_arg0); end
    def downcase(_arg0); end
    def nfc(_arg0); end
    def nfc_safe(_arg0); end
    def nfd(_arg0); end
    def nfd_safe(_arg0); end
    def nfkc(_arg0); end
    def nfkd(_arg0); end
    def normalize_C(_arg0); end
    def normalize_C_safe(_arg0); end
    def normalize_D(_arg0); end
    def normalize_D_safe(_arg0); end
    def normalize_KC(_arg0); end
    def normalize_KD(_arg0); end
    def strcmp(_arg0, _arg1); end
    def strcmp_compat(_arg0, _arg1); end
    def text_elements(_arg0); end
    def upcase(_arg0); end
    def width(*_arg0); end
  end
end

# source://unicode-display_width//lib/unicode/display_width/constants.rb#4
class Unicode::DisplayWidth
  # @return [DisplayWidth] a new instance of DisplayWidth
  #
  # source://unicode-display_width//lib/unicode/display_width.rb#104
  def initialize(ambiguous: T.unsafe(nil), overwrite: T.unsafe(nil), emoji: T.unsafe(nil)); end

  # source://unicode-display_width//lib/unicode/display_width.rb#110
  def get_config(**kwargs); end

  # source://unicode-display_width//lib/unicode/display_width.rb#118
  def of(string, **kwargs); end

  class << self
    # source://unicode-display_width//lib/unicode/display_width/index.rb#14
    def decompress_index(index, level); end

    # source://unicode-display_width//lib/unicode/display_width.rb#86
    def emoji_extra_width_of(string, ambiguous = T.unsafe(nil), overwrite = T.unsafe(nil), _ = T.unsafe(nil)); end

    # source://unicode-display_width//lib/unicode/display_width.rb#12
    def of(string, ambiguous = T.unsafe(nil), overwrite = T.unsafe(nil), options = T.unsafe(nil)); end

    # Same as .width_no_overwrite - but with applying overwrites for each char
    #
    # source://unicode-display_width//lib/unicode/display_width.rb#57
    def width_all_features(string, ambiguous, overwrite, options); end

    # source://unicode-display_width//lib/unicode/display_width.rb#30
    def width_no_overwrite(string, ambiguous, options = T.unsafe(nil)); end
  end
end

# source://unicode-display_width//lib/unicode/display_width.rb#9
Unicode::DisplayWidth::ASCII_NON_ZERO_REGEX = T.let(T.unsafe(nil), Regexp)

# source://unicode-display_width//lib/unicode/display_width/constants.rb#7
Unicode::DisplayWidth::DATA_DIRECTORY = T.let(T.unsafe(nil), String)

# source://unicode-display_width//lib/unicode/display_width.rb#10
Unicode::DisplayWidth::FIRST_4096 = T.let(T.unsafe(nil), Array)

# source://unicode-display_width//lib/unicode/display_width/index.rb#11
Unicode::DisplayWidth::INDEX = T.let(T.unsafe(nil), Array)

# source://unicode-display_width//lib/unicode/display_width/constants.rb#8
Unicode::DisplayWidth::INDEX_FILENAME = T.let(T.unsafe(nil), String)

# source://unicode-display_width//lib/unicode/display_width.rb#8
Unicode::DisplayWidth::INITIAL_DEPTH = T.let(T.unsafe(nil), Integer)

# source://unicode-display_width//lib/unicode/display_width/constants.rb#6
Unicode::DisplayWidth::UNICODE_VERSION = T.let(T.unsafe(nil), String)

# source://unicode-display_width//lib/unicode/display_width/constants.rb#5
Unicode::DisplayWidth::VERSION = T.let(T.unsafe(nil), String)

# frozen_string_literal: true

# The configuration for the transactional outbox
module TransactionalOutbox
  class << self
    attr_accessor :configuration

    def configuration # rubocop:disable Lint/DuplicateMethods
      @configuration ||= TransactionalOutbox::Configuration.new
    end

    def reset
      @configuration = TransactionalOutbox::Configuration.new
    end

    def configure
      yield(configuration)
    end
  end

  # The configuration for the transactional outbox
  class Configuration
    attr_accessor :outbox_mapping

    def initialize
      @outbox_mapping = {}
    end
  end
end

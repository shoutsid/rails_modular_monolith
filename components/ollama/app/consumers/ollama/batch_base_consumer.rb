# frozen_string_literal: true

module Ollama
  # Base consumer for batch consumers
  class BatchBaseConsumer < Karafka::BaseConsumer
    def consume
      messages&.payloads&.each do |payload|
        Ollama::OutboxConsumer.new(payload).consume
      end
    end
  end
end

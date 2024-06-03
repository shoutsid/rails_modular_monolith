# frozen_string_literal: true

module <%= name.camelize.singularize %>
  class BatchBaseConsumer < Karafka::BaseConsumer
    def consume
      messages&.payloads&.each do |payload|
        <%= name.camelize.singularize %>::OutboxConsumer.new(payload).consume
      end
    end
  end
end

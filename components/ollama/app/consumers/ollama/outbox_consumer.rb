# frozen_string_literal: true

module Ollama
  # Consume messages from outbox topic and process them.
  class OutboxConsumer
    EVENTS_MAPPING = {
      Ollama::Events::MESSAGE_CREATED => -> { puts 'Example of lambda & proc as a service' }, # microservices :)
      Ollama::Events::SYNC_EMBEDDING => Ollama::SyncEmbeddingService
    }.freeze

    def initialize(payload)
      @payload = payload
    end

    def consume # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      if Ollama::ConsumedMessage.already_processed?(identifier, aggregate)
        Karafka.logger.info "Already processed event: #{pretty_print_event}"
        nil
      elsif EVENTS_MAPPING.keys.include?(event)
        Karafka.logger.info "New [Ollama::Outbox] event: #{pretty_print_event}"
        consumed_message = Ollama::ConsumedMessage.create!(event_id: identifier, aggregate:,
                                                           status: :processing)
        begin
          EVENTS_MAPPING[event].call(data)
          consumed_message.update!(status: :succeeded)
        rescue StandardError
          consumed_message.update!(status: :failed)
        end
      end
    end

    private

    attr_reader :payload

    def pretty_print_event
      "<identifier: #{identifier}, event: #{event} , aggregate: #{aggregate}>"
    end

    def id
      payload.dig('payload', 'after', 'id')
    end

    def identifier
      payload.dig('payload', 'after', 'identifier')
    end

    def event
      payload.dig('payload', 'after', 'event')
    end

    def aggregate
      payload.dig('payload', 'after', 'aggregate')
    end

    def data
      JSON.parse(payload.dig('payload', 'after', 'payload'))['after']
    end
  end
end

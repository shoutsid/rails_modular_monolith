# frozen_string_literal: true

module Ollama
  # SyncEmbeddingService is a service that syncs embedding data.
  class SyncEmbeddingService < ApplicationService
    attr_accessor :payload, :chunk_id, :chunk, :client

    # @param event_payload [Hash] containing the event payload data.
    def initialize(payload)
      @payload = payload.with_indifferent_access
      @chunk_id = @payload[:chunk_id]
      raise ArgumentError, 'Missing chunk id' if @chunk_id.blank?

      @chunk = Chunk.find(@chunk_id)

      @client ||= Ollama.new(
        credentials: { address: 'http://ollama:11434' },
        options: { server_sent_events: false }
      )

      super
    end

    def call
      embedding = client.embeddings({ model: 'llama3', prompt: chunk.data })[0]
      embedding&.with_indifferent_access
      embedding = embedding.fetch(:embedding, nil)
      chunk.update!(embedding:) unless embedding.nil?
    end
  end
end

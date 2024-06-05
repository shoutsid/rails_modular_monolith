# frozen_string_literal: true

module Ollama
  # SyncEmbeddingsJob is a job that syncs the embeddings of a chunk
  class SyncEmbeddingsJob < ApplicationJob
    queue_as :default
    def client
      @client ||= Ollama.new(
        credentials: { address: 'http://ollama:11434' },
        options: { server_sent_events: true }
      )
    end

    def perform(chunk_id)
      chunk = Chunk.find(chunk_id)
      embedding = client.embeddings({ model: 'llama3', prompt: chunk.data })[0]
      chunk.update!(embedding: embedding['embedding'])
    end
  end
end

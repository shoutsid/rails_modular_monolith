module Ollama
  class CreateChunkJob < ApplicationJob
    def perform(data:, message_ids:)
      messages = Ollama::Message.find(message_ids)
      messages.each do |message|
        message.create_chunk!(data:)
      end
    end
  end
end

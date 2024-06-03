module Ollama
  class CreateChunkJob < ApplicationJob
    def perform(data:, message_ids:)
      messages = Ollama::Message.find(message_ids)
      messages.each do |message|
        message.chunks.build(data:).save!
      end
    end
  end
end

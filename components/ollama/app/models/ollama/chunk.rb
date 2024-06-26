# frozen_string_literal: true

# == Schema Information
#
# Table name: ollama_chunks
#
#  id          :uuid             not null, primary key
#  data        :string           not null
#  embedding   :vector(4096)
#  token_count :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_ollama_chunks_on_created_at  (created_at)
#  index_ollama_chunks_on_updated_at  (updated_at)
#
module Ollama
  # A chunk of text that is being processed by Ollama.
  class Chunk < ApplicationRecord
    include TransactionalOutbox::Outboxable

    has_many :chunks_messages, foreign_key: :ollama_message_id
    has_many :messages, through: :chunks_messages, source: :ollama_message

    has_neighbors :embedding

    scope :with_embedding, -> { where.not(embedding: nil) }
    scope :without_embedding, -> { where(embedding: nil) }

    validates :data, presence: true
    validates :token_count, presence: true

    before_validation :set_token_count, on: :create

    def nearest
      nearest_neighbors(:embedding, distance: :inner_product)
    end

    # Set the known Token count it would of been with GPT-4
    def set_token_count
      self.token_count = Tiktoken.encoding_for_model('gpt-4').encode(data).length
    end
  end
end

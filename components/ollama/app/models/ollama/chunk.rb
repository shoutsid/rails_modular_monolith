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
  class Chunk < ApplicationRecord
    include TransactionalOutbox::Outboxable

    has_and_belongs_to_many :messages, foreign_key: :ollama_message_id, join_table: :ollama_chunks_messages

    has_neighbors :embedding

    scope :with_embedding, -> { where.not(embedding: nil) }
    scope :without_embedding, -> { where(embedding: nil) }

    validates :data, presence: true
    validates :token_count, presence: true

    before_validation :set_token_count, on: :create
    after_create :sync_embeddings

    def nearest
      nearest_neighbors(:embedding, distance: :inner_product)
    end

    def set_token_count
      self.token_count = Tiktoken.encoding_for_model('gpt-4').encode(data).length
    end

    def sync_embeddings
      SyncEmbeddingsJob.perform_later(id)
    end
  end
end

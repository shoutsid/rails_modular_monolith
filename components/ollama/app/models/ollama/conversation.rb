# frozen_string_literal: true

# == Schema Information
#
# Table name: ollama_conversations
#
#  id          :bigint           not null, primary key
#  description :text
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
module Ollama
  # Conversation model
  class Conversation < ApplicationRecord
    include TransactionalOutbox::Outboxable
    has_many :events, foreign_key: :ollama_conversation_id, dependent: :destroy
    has_many :messages, foreign_key: :ollama_conversation_id, dependent: :destroy
  end
end

# frozen_string_literal: true

# == Schema Information
#
# Table name: ollama_events
#
#  id                     :bigint           not null, primary key
#  data                   :json
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  ollama_conversation_id :bigint
#  ollama_message_id      :bigint
#
# Indexes
#
#  index_ollama_events_on_ollama_conversation_id  (ollama_conversation_id)
#  index_ollama_events_on_ollama_message_id       (ollama_message_id)
#
module Ollama
  class Event < ApplicationRecord
    include TransactionalOutbox::Outboxable
    belongs_to :conversation, foreign_key: :ollama_conversation_id, touch: true
    belongs_to :message, foreign_key: :ollama_message_id, touch: true
  end
end

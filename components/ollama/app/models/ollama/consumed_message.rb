# frozen_string_literal: true

# == Schema Information
#
# Table name: ollama_consumed_messages
#
#  id         :bigint           not null, primary key
#  aggregate  :string
#  status     :integer          default("processing"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  event_id   :uuid
#
# Indexes
#
#  index_ollama_consumed_messages_event_id_and_agg  (event_id,aggregate) UNIQUE
#  index_ollama_consumed_messages_status            (status)
#
module Ollama
  class ConsumedMessage < ApplicationRecord
    enum status: {
      processing: 0,
      succeeded: 1,
      failed: 2
    }

    validates_presence_of :aggregate, :event_id

    def self.already_processed?(event_id, aggregate)
      exists?(event_id:, aggregate:, status: %i[processing succeeded])
    end
  end
end

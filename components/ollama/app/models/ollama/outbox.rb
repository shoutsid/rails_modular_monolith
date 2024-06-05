# frozen_string_literal: true

# == Schema Information
#
# Table name: ollama_outboxes
#
#  id                   :bigint           not null, primary key
#  aggregate            :string           not null
#  aggregate_identifier :uuid
#  event                :string           not null
#  identifier           :uuid             not null
#  payload              :jsonb
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_ollama_outboxes_on_aggregate_identifier  (aggregate_identifier)
#  index_ollama_outboxes_on_identifier            (identifier) UNIQUE
#
module Ollama
  # Outbox model
  class Outbox < ApplicationRecord
    validates_presence_of :identifier, :payload, :aggregate, :event
  end
end

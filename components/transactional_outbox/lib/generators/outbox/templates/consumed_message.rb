# frozen_string_literal: true

module <%= name.camelize.singularize %>
  class ConsumedMessage < ApplicationRecord
    enum status: {
      processing: 0,
      succeeded: 1,
      failed: 2
    }

    validates_presence_of :aggregate, :event_id

    def self.already_processed?(event_id, aggregate)
      exists?(event_id: event_id, aggregate: aggregate, status: [:processing, :succeeded])
    end
  end
end

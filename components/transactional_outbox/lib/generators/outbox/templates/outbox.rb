module <%= name.camelize.singularize %>
  class Outbox < ApplicationRecord
    validates_presence_of :identifier, :payload, :aggregate, :event
  end
end

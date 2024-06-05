# frozen_string_literal: true

module DefaultOutbox
  class TestModel < DefaultOutbox::ApplicationRecord
    include TransactionalOutbox::Outboxable
    validates :identifier, presence: true
  end
end

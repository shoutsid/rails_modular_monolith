# frozen_string_literal: true

module TransactionalOutbox
  # Base class for all models
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
    self.table_name_prefix = 'transactional_outbox_'
  end
end

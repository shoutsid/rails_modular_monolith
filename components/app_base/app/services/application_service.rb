# frozen_string_literal: true

# ApplicationService base class
class ApplicationService
  def initialize(*)
    @params = {}
  end

  def self.call(*)
    new(*).call
  end
end

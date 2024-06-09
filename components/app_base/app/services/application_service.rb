# frozen_string_literal: true

# ApplicationService base class
class ApplicationService
  def initialize(*); end

  def self.call(*)
    new(*).call
  end
end

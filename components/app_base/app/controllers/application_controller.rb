# frozen_string_literal: true

# Application controller
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid do |exception|
    render_error(exception)
  end

  def home; end

  protected

  def render_error(exception)
    render json: { errors: { base: [exception.message] } }, status: :unprocessable_entity
  end
end

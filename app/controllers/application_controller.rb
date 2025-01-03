# frozen_string_literal: true

class ApplicationController < ActionController::API
  rescue_from ActionController::ParameterMissing, with: ->(e) { render_error_response(e.message, :bad_request) }

  private

  def render_successful_response(status)
    render json: { data: yield }, status: status
  end

  def render_error_response(errors, status)
    render json: { errors: Array.wrap(errors) }, status: status
  end
end

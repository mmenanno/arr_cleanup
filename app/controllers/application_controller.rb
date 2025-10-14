# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protected

  def show_toast(message, type: "info")
    turbo_stream.append(
      "toasts",
      partial: "shared/toast",
      locals: {
        message:,
        type:,
        dom_id: "toast_#{SecureRandom.hex(8)}",
      },
    )
  end
end

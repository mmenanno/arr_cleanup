# frozen_string_literal: true

class SettingsController < ApplicationController
  def edit
    @app_setting = AppSetting.instance
  end

  def update
    @app_setting = AppSetting.instance
    params_to_update = app_setting_params

    # Don't update API keys if they're blank (keep existing values)
    params_to_update.delete(:radarr_api_key) if params_to_update[:radarr_api_key].blank? && @app_setting.radarr_api_key.present?
    params_to_update.delete(:sonarr_api_key) if params_to_update[:sonarr_api_key].blank? && @app_setting.sonarr_api_key.present?

    if @app_setting.update(params_to_update)
      respond_to do |format|
        format.turbo_stream do
          render(turbo_stream: [
            turbo_stream.replace("radarr-card", partial: "settings/radarr_card", locals: { app_setting: @app_setting }),
            turbo_stream.replace("sonarr-card", partial: "settings/sonarr_card", locals: { app_setting: @app_setting }),
            show_toast("Settings updated successfully", type: "success"),
          ])
        end
        format.html { redirect_to(edit_settings_path, notice: "Settings updated successfully") }
      end
    else
      render(:edit, status: :unprocessable_content)
    end
  end

  def test_radarr_connection
    # Use form values if provided, otherwise use saved values
    radarr_url = params.dig(:app_setting, :radarr_url).presence || AppSetting.instance.radarr_url
    radarr_api_key = params.dig(:app_setting, :radarr_api_key).presence || AppSetting.instance.radarr_api_key

    if radarr_url.blank?
      message = "Please enter a Radarr URL"
      type = "error"
    elsif radarr_api_key.blank?
      message = "Please enter a Radarr API key"
      type = "error"
    else
      service = RadarrService.new(radarr_url, radarr_api_key)
      if service.test_connection
        message = "Radarr connection successful!"
        type = "success"
      else
        message = "Failed to connect to Radarr. Check your URL and API key."
        type = "error"
      end
    end

    render(turbo_stream: show_toast(message, type:))
  end

  def test_sonarr_connection
    # Use form values if provided, otherwise use saved values
    sonarr_url = params.dig(:app_setting, :sonarr_url).presence || AppSetting.instance.sonarr_url
    sonarr_api_key = params.dig(:app_setting, :sonarr_api_key).presence || AppSetting.instance.sonarr_api_key

    if sonarr_url.blank?
      message = "Please enter a Sonarr URL"
      type = "error"
    elsif sonarr_api_key.blank?
      message = "Please enter a Sonarr API key"
      type = "error"
    else
      service = SonarrService.new(sonarr_url, sonarr_api_key)
      if service.test_connection
        message = "Sonarr connection successful!"
        type = "success"
      else
        message = "Failed to connect to Sonarr. Check your URL and API key."
        type = "error"
      end
    end

    render(turbo_stream: show_toast(message, type:))
  end

  def clear_radarr_credentials
    @app_setting = AppSetting.instance
    @app_setting.update(radarr_url: nil, radarr_api_key: nil)

    respond_to do |format|
      format.turbo_stream do
        render(turbo_stream: [
          turbo_stream.replace("radarr-card", partial: "settings/radarr_card", locals: { app_setting: @app_setting }),
          show_toast("Radarr credentials cleared", type: "success"),
        ])
      end
      format.html { redirect_to(edit_settings_path, notice: "Radarr credentials cleared") }
    end
  end

  def clear_sonarr_credentials
    @app_setting = AppSetting.instance
    @app_setting.update(sonarr_url: nil, sonarr_api_key: nil)

    respond_to do |format|
      format.turbo_stream do
        render(turbo_stream: [
          turbo_stream.replace("sonarr-card", partial: "settings/sonarr_card", locals: { app_setting: @app_setting }),
          show_toast("Sonarr credentials cleared", type: "success"),
        ])
      end
      format.html { redirect_to(edit_settings_path, notice: "Sonarr credentials cleared") }
    end
  end

  private

  def app_setting_params
    params.expect(
      app_setting: [
        :radarr_url,
        :radarr_api_key,
        :sonarr_url,
        :sonarr_api_key,
      ],
    )
  end
end

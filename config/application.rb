# frozen_string_literal: true

require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ArrCleanup
  class Application < Rails::Application
    class << self
      def generate_or_load_secret_key_base
        secret_file = Rails.root.join("storage/secret_key_base")

        if secret_file.exist?
          secret_file.read.strip
        else
          require "securerandom"
          new_secret = SecureRandom.hex(64)
          secret_file.dirname.mkpath
          secret_file.write(new_secret)
          secret_file.chmod(0o600) # Secure permissions
          new_secret
        end
      end

      def generate_or_load_encryption_key(key_name)
        key_file = Rails.root.join("storage/#{key_name}")

        if key_file.exist?
          key_file.read.strip
        else
          require "securerandom"
          new_key = SecureRandom.hex(32)
          key_file.dirname.mkpath
          key_file.write(new_key)
          key_file.chmod(0o600) # Secure permissions
          new_key
        end
      end
    end

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults(8.0)

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: ["assets", "tasks"])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "UTC"
    config.active_job.queue_adapter = :solid_queue

    # Auto-generate secret_key_base for distributed deployments
    config.secret_key_base = Rails.application.credentials.secret_key_base ||
      ENV["SECRET_KEY_BASE"] ||
      generate_or_load_secret_key_base

    # Auto-generate Active Record encryption keys for distributed deployments
    config.active_record.encryption.primary_key = ENV["ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY"] ||
      generate_or_load_encryption_key("active_record_encryption_primary_key")
    config.active_record.encryption.deterministic_key = ENV["ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY"] ||
      generate_or_load_encryption_key("active_record_encryption_deterministic_key")
    config.active_record.encryption.key_derivation_salt = ENV["ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT"] ||
      generate_or_load_encryption_key("active_record_encryption_key_derivation_salt")
  end
end

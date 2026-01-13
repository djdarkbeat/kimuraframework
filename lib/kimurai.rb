require 'ostruct'
require 'logger'
require 'json'
require 'uri'

require 'active_support'
require 'active_support/core_ext'
require 'rbcat'
require 'nukitori'

require_relative 'kimurai/version'

require_relative 'kimurai/core_ext/numeric'
require_relative 'kimurai/core_ext/string'
require_relative 'kimurai/core_ext/array'
require_relative 'kimurai/core_ext/hash'

require_relative 'kimurai/browser_builder'
require_relative 'kimurai/base_helper'
require_relative 'kimurai/pipeline'
require_relative 'kimurai/base'

module Kimurai
  # Settings that will be forwarded to Nukitori configuration
  NUKITORI_SETTINGS = %i[
    openai_api_key
    anthropic_api_key
    gemini_api_key
    vertexai_project_id
    vertexai_location
    deepseek_api_key
    mistral_api_key
    perplexity_api_key
    openrouter_api_key
    gpustack_api_key
    openai_api_base
    gemini_api_base
    ollama_api_base
    gpustack_api_base
    openai_organization_id
    openai_project_id
    openai_use_system_role
    bedrock_api_key
    bedrock_secret_key
    bedrock_region
    bedrock_session_token
    default_model
    model_registry_file
  ].freeze

  class << self
    def configuration
      @configuration ||= OpenStruct.new
    end

    def configure
      yield(configuration)
      apply_nukitori_configuration
    end

    def apply_nukitori_configuration
      nukitori_settings = NUKITORI_SETTINGS.filter_map do |setting|
        value = configuration[setting]
        [setting, value] if value
      end.to_h

      return if nukitori_settings.empty?

      Nukitori.configure do |config|
        nukitori_settings.each do |setting, value|
          config.public_send("#{setting}=", value)
        end
      end
    end

    def env
      ENV.fetch('KIMURAI_ENV', 'development')
    end

    def time_zone
      ENV['TZ']
    end

    def time_zone=(value)
      ENV.store('TZ', value)
    end

    def list
      Base.descendants.map do |klass|
        next unless klass.name

        [klass.name, klass]
      end.compact.to_h
    end

    def find_by_name(name)
      return unless name

      Base.descendants.find { |klass| klass.name == name }
    end
  end
end

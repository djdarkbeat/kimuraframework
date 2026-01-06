module Kimurai
  module BrowserBuilder
    ENGINE_ALIASES = {
      chrome: :selenium_chrome,
      firefox: :selenium_firefox
    }.freeze

    def self.build(engine, config = {}, spider:)
      engine = ENGINE_ALIASES.fetch(engine, engine)

      begin
        require "kimurai/browser_builder/#{engine}_builder"
      rescue LoadError
      end

      builder_class_name = "#{engine}_builder".classify
      builder = "Kimurai::BrowserBuilder::#{builder_class_name}".constantize
      builder.new(config, spider: spider).build
    end
  end
end

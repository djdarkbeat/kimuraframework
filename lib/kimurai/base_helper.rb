module Kimurai
  module BaseHelper
    def extract(response, model: nil, &block)
      caller_info = caller_locations(1, 1).first
      method_name = caller_info.base_label
      spider_dir = File.dirname(caller_info.path)
      schema_path = File.join(spider_dir, "#{self.class.name}.json")

      data = Nukitori(response, schema_path, prefix: method_name, model:, &block)
      data.deep_symbolize_keys
    end

    private

    def absolute_url(url, base:)
      return unless url

      URI.join(base, URI::DEFAULT_PARSER.escape(url)).to_s
    end

    def escape_url(url)
      URI.parse(url)
    rescue URI::InvalidURIError
      URI.parse(URI::DEFAULT_PARSER.escape(url)).to_s rescue url
    else
      url
    end

    def normalize_url(url, base:)
      escape_url(absolute_url(url, base: base))
    end
  end
end

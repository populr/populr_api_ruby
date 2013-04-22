require 'rest-client'
require 'restful_model_collection'
require 'template'
require 'document_asset'
require 'image_asset'
require 'json'
require 'pop'
require 'domain'


class Populr

  class AccessDenied < StandardError; end
  class ResourceNotFound < StandardError; end
  class UnexpectedResponse < StandardError; end
  class APIError < StandardError
    attr_accessor :error_type
    def initialize(type, error)
      super(error)
      self.error_type = type
    end
  end

  attr_accessor :api_server
  attr_reader :api_key
  attr_reader :api_version


  def self.interpret_response(result, options = {})
    # Handle HTTP errors and RestClient errors
    raise ResourceNotFound.new if result.code.to_i == 404
    raise AccessDenied.new if result.code.to_i == 403

    # Hande content expectation errors
    raise UnexpectedResponse.new if options[:expected_class] && result.body.empty?
    json = JSON.parse(result.body)
    raise APIError.new(json['error_type'], json['error']) if json.is_a?(Hash) && json['error_type']
    raise UnexpectedResponse.new(result.msg) if result.is_a?(Net::HTTPClientError)
    raise UnexpectedResponse.new if options[:expected_class] && !json.is_a?(options[:expected_class])
    json

  rescue JSON::ParserError => e
    # Handle parsing errors
    raise UnexpectedResponse.new(e.message)
  end



  def initialize(api_key, api_server = 'https://api.populr.me')
    raise "When overriding the Populr API server address, you must include https://" unless api_server.include?('://')
    @api_server = api_server
    @api_version = 'v0'
    @api_key = api_key

    RestClient.add_before_execution_proc do |req, params|
      req.add_field('X-Populr-API-Wrapper', 'ruby')
    end
  end

  def templates
    @templates ||= RestfulModelCollection.new(Template, self)
    @templates
  end

  def pops
    @pops ||= RestfulModelCollection.new(Pop, self)
    @pops
  end

  def domains
    @domains ||= RestfulModelCollection.new(Domain, self)
    @domains
  end

  def documents
    @documents ||= RestfulModelCollection.new(DocumentAsset, self)
    @documents
  end

  def images
    @images ||= RestfulModelCollection.new(ImageAsset, self)
    @images
  end

  def embeds
    @embeds ||= RestfulModelCollection.new(EmbedAsset, self)
    @embeds
  end

  def url_for_path(path)
    protocol, domain = @api_server.split('//')
    "#{protocol}//#{@api_key}:@#{domain}/#{@api_version}#{path}"
  end


end
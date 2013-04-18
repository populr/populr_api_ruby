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



  def initialize(api_key)
    @api_server = "api.lvh.me:3000"
    @api_key = api_key
  end

  def templates
    RestfulModelCollection.new(Template, self)
  end

  def pops
    RestfulModelCollection.new(Pop, self)
  end

  def domains
    RestfulModelCollection.new(Domain, self)
  end

  def documents
    RestfulModelCollection.new(DocumentAsset, self)
  end

  def images
    RestfulModelCollection.new(ImageAsset, self)
  end

  def url_for_path(path)
    "http://#{@api_key}:@#{api_server}#{path}"
  end


end
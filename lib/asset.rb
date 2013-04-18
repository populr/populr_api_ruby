require 'restful_model'

class Asset < RestfulModel

  attr_accessor :description
  attr_accessor :title

  # as an alternative to calling Asset.new, you can call populr.images.build
  def initialize(api, file, title = nil, description = nil)
    super(api)

    @file = file
    self.title = title
    self.description = description
  end

  def as_json(options = {})
    hash = super(options)
    hash[:file] = @file if options[:api_representation] && @file
    hash
  end

end
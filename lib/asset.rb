require 'restful_model'

class Asset < RestfulModel

  attr_accessor :description
  attr_accessor :title

  # as an alternative to calling Asset.new, you can call populr.images.build
  def initialize(parent = nil, file = nil, title = nil, description = nil)
    super(parent)

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
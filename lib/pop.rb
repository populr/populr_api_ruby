require 'restful_model'
require 'tracer'

class Pop < RestfulModel

  class TemplateRequired < StandardError; end
  class AssetMustBeSaved < StandardError; end

  attr_accessor :template_id
  attr_accessor :name
  attr_accessor :title
  attr_accessor :slug
  attr_accessor :label_names
  attr_accessor :tracers
  attr_accessor :published_pop_url
  attr_accessor :unpopulated_api_regions
  attr_accessor :unpopulated_api_tags
  attr_accessor :domain
  attr_accessor :password

  attr_reader :newly_populated_regions
  attr_reader :newly_populated_tags

  def initialize(parent)
    if parent.is_a?(Template)
      @_api = parent.instance_variable_get :@_api
      self.template_id = parent._id
      self.unpopulated_api_regions = parent.api_regions
      self.unpopulated_api_tags = parent.api_tags

    elsif parent.is_a?(RestfulModelCollection)
      @_api = parent.instance_variable_get :@_api

    elsif parent.is_a?(Populr)
      @_api = parent
    else
      raise "You must create a pop with a template, collection, or API model."
    end

    # We could choose to make parent the restfulModelCollection that is passed to us,
    # but that would result in PUTs and POSTs to /templates/:id/pops, which isn't
    # how the API is currently set up. For now, all pop PUTS, POSTs, etc... go to /pops/
    @_parent = @_api.pops

    @newly_populated_regions = {}
    @newly_populated_tags = {}
  end

  def inflate(json)
    super(json)

    self.tracers = RestfulModelCollection.new(Tracer, @_api, self)
    @newly_populated_regions = {}
    @newly_populated_tags = {}
  end

  def as_json(options = {})
    raise TemplateRequired.new if options[:api_representation] && !template_id

    if options[:api_representation]
      hash = {}
      hash[:pop] = super(options)
      hash[:populate_tags] = @newly_populated_tags
      hash[:populate_regions] = @newly_populated_regions
      hash
    else
      super(options)
    end
  end


  def publish!
    update('POST', 'publish')
  end

  def unpublish!
    update('POST', 'unpublish')
  end

  def has_unpopulated_region(region_identifier)
    self.unpopulated_api_regions.include?(region_identifier)
  end

  def type_of_unpopulated_region(region_identifier)
    return false unless self.has_unpopulated_region(region_identifier)
    self.unpopulated_api_regions[region_identifier]['type']
  end

  def populate_region(region_identifier, assets)
    assets = [assets] unless assets.is_a?(Array)

    @newly_populated_regions[region_identifier] ||= []
    @newly_populated_regions[region_identifier].concat(assets.map {|a|
      raise AssetMustBeSaved.new unless a._id
      a._id
    })
    self.unpopulated_api_regions.delete(region_identifier)
  end

  def has_unpopulated_tag(tag_identifier)
    self.unpopulated_api_tags.include?(tag_identifier)
  end

  def populate_tag(tag_identifier, tag_contents)
    @newly_populated_tags[tag_identifier] = tag_contents
    self.unpopulated_api_tags.delete(tag_identifier)
  end


end
require 'restful_model'
require 'tracer'

class Pop < RestfulModel

  class TemplateRequired < StandardError; end

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

  def initialize(api_or_template, template = nil)
    template = template || api_or_template

    if template.is_a?(Template)
      self.template_id = template._id
      @_api = template._api
    else
      @_api = api_or_template
    end

    @newly_populated_regions = {}
    @newly_populated_tags = {}
  end

  def inflate(json)
    super(json)

    collection = RestfulModelCollection.new(Tracer, @_api, self)
    collection.inflate_collection(self.tracers) if self.tracers
    self.tracers = collection

    @newly_populated_regions = {}
    @newly_populated_tags = {}
  end

  def to_json(options = {})
    raise TemplateRequired.new unless template_id

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

  def populate_region(region_identifier, assets)
    assets = [assets] unless assets.is_a?(Array)

    @newly_populated_regions[region_identifier] ||= []
    @newly_populated_regions[region_identifier].concat(assets.map {|a| a._id })
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
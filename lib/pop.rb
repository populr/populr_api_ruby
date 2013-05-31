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
  attr_accessor :custom_links
  attr_accessor :custom_code
  attr_accessor :clone_link_enabled
  attr_accessor :clone_link_url
  attr_accessor :collaboration_link_enabled
  attr_accessor :collaboration_interstitial_text
  attr_accessor :collaboration_link_url
  attr_accessor :collaboration_webhook
  attr_accessor :background_image_asset_id
  attr_accessor :domain
  attr_accessor :password

  attr_reader :newly_populated_regions
  attr_reader :newly_populated_tags

  def initialize(parent)
    if parent.is_a?(Template)
      @_api = parent.instance_variable_get :@_api
      self.template_id = parent._id
      self.title = parent.title
      self.name = parent.name
      self.domain = parent.domain
      self.password = parent.password
      self.label_names = parent.label_names.dup if parent.label_names
      self.background_image_asset_id = parent.background_image_asset_id
      self.unpopulated_api_regions = parent.api_regions.dup
      self.unpopulated_api_tags = parent.api_tags.dup
      self.custom_code = parent.custom_code
      self.custom_links = parent.custom_links.dup if parent.custom_links

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

  def edit_url
    return @_api.api_server.gsub('api.', 'www.') + "/edit/#{self._id}"
  end

  def enable_collaboration!(interstitial_text = '', webhook = nil)
    self.collaboration_link_enabled = true
    self.collaboration_webhook = webhook
    self.collaboration_interstitial_text = interstitial_text
    self.save! # go and populate our model with the collaboration link
  end

  def disable_collaboration
    self.collaboration_link_enabled = false
    self.collaboration_link_url = nil
  end

  def enable_cloning!
    self.clone_link_enabled = true
    self.save! # go and populate our model with the clone link
  end

  def disable_cloning
    self.clone_link_enabled = false
    self.clone_link_url = nil # doesn't get saed, just for developer interface
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
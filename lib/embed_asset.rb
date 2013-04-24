require 'asset'

class EmbedAsset < Asset

  attr_accessor :source_html

  def self.collection_name
    "embeds"
  end

  # as an alternative to calling Asset.new, you can call populr.images.build
  def initialize(parent, source_html, title = nil, description = nil)
    super(parent, nil)

    @source_html = source_html
    self.title = title
    self.description = description
  end

end


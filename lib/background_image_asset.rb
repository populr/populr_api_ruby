require 'asset'

class BackgroundImageAsset < Asset

  attr_accessor :link

  def self.collection_name
    "background_images"
  end

end


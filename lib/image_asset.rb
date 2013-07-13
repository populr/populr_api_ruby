require 'asset'

class ImageAsset < Asset

  attr_accessor :link

  def self.collection_name
    'images'
  end

end


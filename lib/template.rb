require 'restful_model'

class Template < RestfulModel

  attr_accessor :title
  attr_accessor :name
  attr_accessor :label_names
  attr_accessor :api_tags
  attr_accessor :api_regions
  attr_accessor :custom_code
  attr_accessor :custom_links

  def pops
    @pops ||= RestfulModelCollection.new(Pop, @_api, self)
  end

end
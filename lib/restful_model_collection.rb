require 'restful_model'

class RestfulModelCollection

  def initialize(model_class, api, parent = nil)
    @model_class = model_class
    @_parent = parent
    @_api = api
  end

  def each
    offset = 0
    finished = false
    while (!finished) do
      items = get_restful_model_collection(offset)
      break if items.length == 0
      items.each { |item|
        yield item
      }
      offset += items.length
    end
  end

  def first
    get_restful_model_collection.first
  end

  def all
    range(0, Float::INFINITY)
  end

  def range(offset = 0, count = 50)
    accumulated = []
    finished = false
    chunk_size = 50

    while (!finished && accumulated.length < count) do
      results = get_restful_model_collection(offset + accumulated.length, chunk_size)
      accumulated = accumulated.concat(results)

      # we're done if we have more than 'count' items, or if we asked for 50 and got less than 50...
      finished = accumulated.length >= count || results.length == 0 || (results.length % chunk_size != 0)
    end

    accumulated = accumulated[0..count] if count < Float::INFINITY
    accumulated
  end

  def delete(item_or_id)
    item_or_id = item_or_id._id if item_or_id.is_a?(RestfulModel)
    url = @_api.url_for_path(self.path(item_or_id))
    RestClient.delete(url)
  end

  def find(id)
    return nil unless id
    get_restful_model(id)
  end

  def build(*args)
    @model_class.new(self, *args)
  end

  def inflate_collection(items = [])
    models = []

    return unless items.is_a?(Array)
    items.each do |json|
      if @model_class < RestfulModel
        model = @model_class.new(self)
        model.inflate(json)
      else
        model = @model_class.new(json)
      end
      models.push(model)
    end
    models
  end

  def path(id = "")
    prefix = @_parent ? @_parent.path : ''
    "#{prefix}/#{@model_class.collection_name}/#{id}"
  end

  private

  def get_restful_model(id)
    model = nil
    url = @_api.url_for_path(self.path(id))

    RestClient.get(url){ |response,request,result|
      json = Populr.interpret_response(result, {:expected_class => Object})
      if @model_class < RestfulModel
        model = @model_class.new(self)
        model.inflate(json)
      else
        model = @model_class.new(json)
      end
    }
    model
  end

  def get_restful_model_collection(offset = 0, count = 50)
    url = @_api.url_for_path("#{self.path}?offset=#{offset}&count=#{count}")
    models = []

    RestClient.get(url){ |response,request,result|
      items = Populr.interpret_response(result, {:expected_class => Array})
      models = inflate_collection(items)
    }
    models
  end

end

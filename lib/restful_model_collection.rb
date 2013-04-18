require 'restful_model'

class RestfulModelCollection

  def initialize(model_class, api, parent = nil)
    @model_class = model_class
    @_parent = parent
    @_collection = nil
    @_api = api
  end

  def all
    return @_collection if @_collection
    get_restful_model_collection
  end

  def first
    all.first
  end

  def find(id)
    return nil unless id
    get_restful_model(id)
  end

  def build(*args)
    @model_class.new(@_api, *args)
  end

  def as_json(options = {})
    objects = []
    for model in self.all
      objects.push(model.as_json(options))
    end
    objects
  end

  def inflate_collection(items = [])
    @_collection = []

    return unless items.is_a?(Array)
    items.each do |json|
      if @model_class < RestfulModel
        model = @model_class.new(self)
        model.instance_variable_set(:@_parent, @_parent)
        model.inflate(json)
      else
        model = @model_class.new(json)
      end
      @_collection.push(model)
    end
    @_collection
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
        model = @model_class.new(@_api)
        model.instance_variable_set(:@_parent, @_parent)
        model.inflate(json)
      else
        model = @model_class.new(json)
      end
    }
    model
  end

  def get_restful_model_collection
    url = @_api.url_for_path(self.path)

    RestClient.get(url){ |response,request,result|
      items = Populr.interpret_response(result, {:expected_class => Array})
      inflate_collection(items)
    }
    @_collection
  end

end

class RestfulModel

  attr_accessor :_id
  attr_accessor :created_at

  def self.collection_name
    "#{self.to_s.downcase}s"
  end


  def initialize(api)
    @_api = api
  end

  def ==(comparison_object)
    comparison_object.equal?(self) || (comparison_object.instance_of?(self.class) && comparison_object._id == _id)
  end

  def inflate(json)
    setters = methods.grep(/^\w+=$/)
    setters.each do |setter|
      property_name = setter.to_s[0..setter.to_s.index('=')-1]
      self.send(setter, json[property_name]) if json.has_key?(property_name)
    end
    self.created_at = Time.new(self.created_at) if self.created_at
  end

  def save!
    if _id
      update('PUT', '', self.to_json(:api_representation => true))
    else
      update('POST', '', self.to_json(:api_representation => true))
    end
  end

  def update(http_method, action, data = {})
    http_method = http_method.downcase
    action_url = @_api.url_for_path(self.path(action))

    RestClient.send(http_method, action_url, data){ |response,request,result|
      json = Populr.interpret_response(result, {:expected_class => Object})
      inflate(json)
    }
    self
  end

  def path(action = "")
    action = "/#{action}" unless action.empty?
    prefix = @_parent ? @_parent.path : ''
    "#{prefix}/#{self.class.collection_name}/#{_id}#{action}"
  end


end
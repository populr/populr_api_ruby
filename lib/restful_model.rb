class RestfulModel

  attr_accessor :_id
  attr_accessor :created_at

  def self.collection_name
    "#{self.to_s.downcase}s"
  end


  def initialize(parent)
    if parent.is_a?(Populr)
      @_api = parent
    else
      @_parent = parent
      @_api = parent.instance_variable_get :@_api
    end
  end

  def ==(comparison_object)
    comparison_object.equal?(self) || (comparison_object.instance_of?(self.class) && comparison_object._id == _id)
  end

  def inflate(json)
    setters = methods.grep(/^\w+=$/)
    setters.each do |setter|
      property_name = setter.to_s.sub('=', '')
      send(setter, json[property_name]) if json.has_key?(property_name)
    end
  end

  def save!
    if _id
      update('PUT', '', as_json(:api_representation => true))
    else
      update('POST', '', as_json(:api_representation => true))
    end
  end

  def as_json(options = {})
    hash = {}
    setters = methods.grep(/^\w+=$/)
    setters.each do |setter|
      getter = setter.to_s.sub('=', '')
      unless options[:except] && options[:except].include?(getter)
        value = send(getter)
        unless value.is_a?(RestfulModelCollection)
          value = value.as_json(options) if value.respond_to?(:as_json)
          hash[getter] = value
        end
      end
    end
    hash
  end

  def update(http_method, action, data = {})
    http_method = http_method.downcase
    action_url = @_api.url_for_path(path(action))

    RestClient.send(http_method, action_url, data) do |response, request, result|
      unless http_method == 'delete'
        json = Populr.interpret_response(result, response, :expected_class => Object)
        inflate(json)
      end
    end
    self
  end

  def destroy
    update('DELETE', '')
  end

  def path(action = "")
    action = "/#{action}" unless action.empty?
    prefix = @_parent ? @_parent.path : ''
    "#{prefix}#{_id}#{action}"
  end


end

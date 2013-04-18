::ENV['RACK_ENV'] = 'test'
require File.join(File.dirname(__FILE__), 'spec_helper')
require 'rack/test'

describe 'RestfulModelCollection' do
  include Rack::Test::Methods

  before (:each) do
    @api_key = 'UXXMOCJW-BKSLPCFI-UQAQFWLO'
    @populr = Populr.new(@api_key)
    @collection = @populr.pops
  end

  describe "#all" do
    it "should call interpret_response to handle standard error cases" do
      Populr.should_receive(:interpret_response).and_return([])
      templates = @populr.templates.all
    end

    context "when the model class is a RestfulModel" do
      context "when the server responds correctly" do
        before (:each) do
          result = double('result')
          result.stub(:body).and_return("[{\"_id\":\"5107089add02dcaecc000003\",\"created_at\":\"2013-01-28T23:24:10Z\",\"domain\":\"generic\",\"name\":\"Untitled\",\"password\":null,\"slug\":\"\",\"tracers\":[{\"_id\":\"5109b5e0dd02dc5976000001\",\"created_at\":\"2013-01-31T00:08:00Z\",\"name\":\"Facebook\"},{\"_id\":\"5109b5f5dd02dc4c43000002\",\"created_at\":\"2013-01-31T00:08:21Z\",\"name\":\"Twitter\"}],\"published_pop_url\":\"http://group3.lvh.me\",\"unpopulated_api_tags\":[],\"unpopulated_api_regions\":[],\"label_names\":[]}]")
          result.stub(:code).and_return(200)
          RestClient.should_receive(:get).and_yield(nil, nil, result)
        end

        it "should return an array of model objects" do
          pops = @collection.all
          pops.count.should == 1
          pops.first.is_a?(RestfulModel).should == true
        end

        it "should call inflate on each model object" do
          Pop.any_instance.should_receive(:inflate)
          pops = @collection.all
        end
      end
    end

    context "when the model class is not a restfulModel" do
      it "should return the same data type in the JSON" do
        result = double('result')
        result.stub(:body).and_return("[\"a\",\"b\",\"c\"]")
        result.stub(:code).and_return(200)
        RestClient.should_receive(:get).and_yield(nil, nil, result)
        @populr.domains.all.should == ['a','b','c']
      end
    end
  end

  describe "#first" do
    it "should return the first item in the all collection" do
      result = double('result')
      result.stub(:body).and_return("[{\"_id\":\"5107089add02dcaecc000003\",\"created_at\":\"2013-01-28T23:24:10Z\",\"domain\":\"generic\",\"name\":\"Untitled\",\"password\":null,\"slug\":\"\",\"tracers\":[{\"_id\":\"5109b5e0dd02dc5976000001\",\"created_at\":\"2013-01-31T00:08:00Z\",\"name\":\"Facebook\"},{\"_id\":\"5109b5f5dd02dc4c43000002\",\"created_at\":\"2013-01-31T00:08:21Z\",\"name\":\"Twitter\"}],\"published_pop_url\":\"http://group3.lvh.me\",\"unpopulated_api_tags\":[],\"unpopulated_api_regions\":[],\"label_names\":[]}]")
      result.stub(:code).and_return(200)
      RestClient.should_receive(:get).and_yield(nil, nil, result)
      @collection.first.should == @collection.all.first
    end
  end

  describe "#find" do
    it "should call interpret_response to handle standard error cases" do
      Populr.should_receive(:interpret_response).and_return({})
      @populr.pops.find('123')
    end

    context "when the server responds correctly" do
      before (:each) do
        result = double('result')
        result.stub(:body).and_return("{\"_id\":\"5107089add02dcaecc000003\",\"created_at\":\"2013-01-28T23:24:10Z\",\"domain\":\"generic\",\"name\":\"Untitled\",\"password\":null,\"slug\":\"\",\"tracers\":[{\"_id\":\"5109b5e0dd02dc5976000001\",\"created_at\":\"2013-01-31T00:08:00Z\",\"name\":\"Facebook\"},{\"_id\":\"5109b5f5dd02dc4c43000002\",\"created_at\":\"2013-01-31T00:08:21Z\",\"name\":\"Twitter\"}],\"published_pop_url\":\"http://group3.lvh.me\",\"unpopulated_api_tags\":[],\"unpopulated_api_regions\":[],\"label_names\":[]}")
        result.stub(:code).and_return(200)
        RestClient.should_receive(:get).and_yield(nil, nil, result)
      end

      it "should return a pop" do
        pop = @collection.find('5107089add02dcaecc000003')
        pop.is_a?(Pop).should == true
        pop._id.should == '5107089add02dcaecc000003'
      end
    end
  end

  describe "#build" do
    it "should create a new instance of the model object" do
      parameter1 = double('parameter1')
      image = @populr.images.build(parameter1)
      image.is_a?(ImageAsset).should == true
    end

    it "should pass the api reference, and then any provided arguments" do
      parameter1 = double('parameter1')
      ImageAsset.any_instance.should_receive(:initialize).with(@populr, parameter1)
      @populr.images.build(parameter1)
    end
  end

  describe "#as_json" do
    before (:each) do
      result = double('result')
      result.stub(:body).and_return("[{\"_id\":\"5107089add02dcaecc000003\",\"template_id\":\"5107089add02dcaecc000001\",\"created_at\":\"2013-01-28T23:24:10Z\",\"domain\":\"generic\",\"name\":\"Untitled\",\"password\":null,\"slug\":\"\",\"tracers\":[{\"_id\":\"5109b5e0dd02dc5976000001\",\"created_at\":\"2013-01-31T00:08:00Z\",\"name\":\"Facebook\"},{\"_id\":\"5109b5f5dd02dc4c43000002\",\"created_at\":\"2013-01-31T00:08:21Z\",\"name\":\"Twitter\"}],\"published_pop_url\":\"http://group3.lvh.me\",\"unpopulated_api_tags\":[],\"unpopulated_api_regions\":[],\"label_names\":[]}]")
      result.stub(:code).and_return(200)
      RestClient.should_receive(:get).and_yield(nil, nil, result)
    end

    it "should call as_json for each model in the collection" do
      Pop.any_instance.should_receive(:as_json)
      @collection.as_json
    end

    it "should return an array of hashes" do
      @collection.as_json.count.should == 1
      @collection.as_json.first['_id'].should == '5107089add02dcaecc000003'
    end

    it "should forward options to each model" do
      Pop.any_instance.should_receive(:as_json).with(:bla => true)
      @collection.as_json(:bla => true)
    end
  end

end

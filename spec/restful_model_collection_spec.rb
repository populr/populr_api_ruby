::ENV['RACK_ENV'] = 'test'
require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'RestfulModelCollection' do
  before (:each) do
    @api_key = 'UXXMOCJW-BKSLPCFI-UQAQFWLO'
    @populr = Populr.new(@api_key)
    @collection = @populr.pops
  end

  describe "#first" do
    it "should return the first item in the all collection" do
      @collection.stub(:get_restful_model_collection).and_return(['a','b'])
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
        result.stub(:code).and_return(200)
        RestClient.should_receive(:get).and_yield("{\"_id\":\"5107089add02dcaecc000003\",\"created_at\":\"2013-01-28T23:24:10Z\",\"domain\":\"generic\",\"name\":\"Untitled\",\"password\":null,\"slug\":\"\",\"tracers\":[{\"_id\":\"5109b5e0dd02dc5976000001\",\"created_at\":\"2013-01-31T00:08:00Z\",\"name\":\"Facebook\"},{\"_id\":\"5109b5f5dd02dc4c43000002\",\"created_at\":\"2013-01-31T00:08:21Z\",\"name\":\"Twitter\"}],\"published_pop_url\":\"http://group3.lvh.me\",\"unpopulated_api_tags\":[],\"unpopulated_api_regions\":[],\"label_names\":[]}", nil, result)
      end

      it "should return a pop" do
        pop = @collection.find('5107089add02dcaecc000003')
        pop.is_a?(Pop).should == true
        pop._id.should == '5107089add02dcaecc000003'
      end
    end

    context "on an image asset" do
      before (:each) do
        result = double('result')
        result.stub(:code).and_return(200)
        RestClient.should_receive(:get).and_yield("{\"_id\":\"5107089add02dcaecc000003\",\"created_at\":\"2013-01-28T23:24:10Z\",\"domain\":\"generic\",\"name\":\"Untitled\",\"password\":null,\"slug\":\"\",\"tracers\":[{\"_id\":\"5109b5e0dd02dc5976000001\",\"created_at\":\"2013-01-31T00:08:00Z\",\"name\":\"Facebook\"},{\"_id\":\"5109b5f5dd02dc4c43000002\",\"created_at\":\"2013-01-31T00:08:21Z\",\"name\":\"Twitter\"}],\"published_pop_url\":\"http://group3.lvh.me\",\"unpopulated_api_tags\":[],\"unpopulated_api_regions\":[],\"label_names\":[]}", nil, result)
        @collection = @populr.images
      end

      it "should return an image asset" do
        pop = @collection.find('5107089add02dcaecc000003')
        pop.is_a?(ImageAsset).should == true
        pop._id.should == '5107089add02dcaecc000003'
      end
    end

    context "on a document asset" do
      before (:each) do
        result = double('result')
        result.stub(:code).and_return(200)
        RestClient.should_receive(:get).and_yield("{\"_id\":\"5107089add02dcaecc000003\",\"created_at\":\"2013-01-28T23:24:10Z\",\"domain\":\"generic\",\"name\":\"Untitled\",\"password\":null,\"slug\":\"\",\"tracers\":[{\"_id\":\"5109b5e0dd02dc5976000001\",\"created_at\":\"2013-01-31T00:08:00Z\",\"name\":\"Facebook\"},{\"_id\":\"5109b5f5dd02dc4c43000002\",\"created_at\":\"2013-01-31T00:08:21Z\",\"name\":\"Twitter\"}],\"published_pop_url\":\"http://group3.lvh.me\",\"unpopulated_api_tags\":[],\"unpopulated_api_regions\":[],\"label_names\":[]}", nil, result)
        @collection = @populr.documents
      end

      it "should return a document asset" do
        pop = @collection.find('5107089add02dcaecc000003')
        pop.is_a?(DocumentAsset).should == true
        pop._id.should == '5107089add02dcaecc000003'
      end
    end

    context "on an embed asset" do
      before (:each) do
        result = double('result')
        result.stub(:code).and_return(200)
        RestClient.should_receive(:get).and_yield("{\"_id\":\"5107089add02dcaecc000003\",\"created_at\":\"2013-01-28T23:24:10Z\",\"domain\":\"generic\",\"name\":\"Untitled\",\"password\":null,\"slug\":\"\",\"tracers\":[{\"_id\":\"5109b5e0dd02dc5976000001\",\"created_at\":\"2013-01-31T00:08:00Z\",\"name\":\"Facebook\"},{\"_id\":\"5109b5f5dd02dc4c43000002\",\"created_at\":\"2013-01-31T00:08:21Z\",\"name\":\"Twitter\"}],\"published_pop_url\":\"http://group3.lvh.me\",\"unpopulated_api_tags\":[],\"unpopulated_api_regions\":[],\"label_names\":[]}", nil, result)
        @collection = @populr.embeds
      end

      it "should return an embed asset" do
        pop = @collection.find('5107089add02dcaecc000003')
        pop.is_a?(EmbedAsset).should == true
        pop._id.should == '5107089add02dcaecc000003'
      end
    end

    it "should return nil and not throw an exception if you fail to pass an ID" do
      @populr.pops.find(nil).should == nil
    end
  end

  describe "#delete" do
    it "should accept a model to delete" do
      RestClient.should_receive(:delete).with(@populr.url_for_path(@populr.images.path('123')))
      a = ImageAsset.new(@api, nil)
      a._id = '123'
      @populr.images.delete(a)
    end

    it "should accept a string ID to delete" do
      RestClient.should_receive(:delete).with(@populr.url_for_path(@populr.images.path('123')))
      @populr.images.delete('123')
    end
  end

  describe "#build" do
    it "should create a new instance of the model object" do
      parameter1 = double('parameter1')
      image = @populr.images.build(parameter1)
      image.is_a?(ImageAsset).should == true
    end

    it "should pass the collection, and then any provided arguments" do
      parameter1 = double('parameter1')
      images = @populr.images
      ImageAsset.any_instance.should_receive(:initialize).with(images, parameter1)
      images.build(parameter1)
    end
  end

  describe "#all" do
    it "should be a shorthand for requesting the entire range" do
      @populr.images.should_receive(:range).with(0, Float::INFINITY)
      @populr.images.all
    end
  end

  describe "#each" do
    it "should yield each item, starting with the first one" do
      @populr.images.should_receive(:get_restful_model_collection).with(0).and_return(['a','b','c'])
      @populr.images.should_receive(:get_restful_model_collection).with(3).and_return(['d','e','f'])
      @populr.images.should_receive(:get_restful_model_collection).with(6).and_return([])

      yields = []
      @populr.images.each do |item|
        yields.push(item)
      end
      yields.should == ['a','b','c','d','e','f']
    end
  end

  describe "#path" do
    it "should prepend it's parent's path if one exists" do
      parent = double('parent')
      parent.stub('path').and_return('/parent/50')
      @populr.images.instance_variable_set(:@_parent, parent)
      @populr.images.path.should == '/parent/50/images/'
    end

    it "should generate the path using it's model class' collection name" do
      ImageAsset.should_receive(:collection_name).and_return('collection')
      @populr.images.path.should == '/collection/'
    end

    context "when provided with an ID" do
      it "should append that ID to the end of the collection URL" do
        @populr.images.path(5).should == '/images/5'
      end
    end
  end

  describe "#range" do
    before (:each) do
      @items = []
      200.times do
        @items.push((65 + rand(25)).chr)
      end
    end

    it "should return the first fifty rows by default" do
      @populr.images.should_receive(:get_restful_model_collection).with(0,50).and_return(@items[0..49])
      @populr.images.range.should == @items[0..49]
    end

    context "when a count is provided" do
      it "should fetch chunks until it has enough rows, and then return exactly the number requested" do
        @populr.images.should_receive(:get_restful_model_collection).with(0,50).and_return(@items[0..49])
        @populr.images.should_receive(:get_restful_model_collection).with(50,50).and_return(@items[50..99])
        @populr.images.range(0,100).count.should == 100
      end

      it "should return early if a request for a chunk returns fewer rows than requested" do
        @populr.images.should_receive(:get_restful_model_collection).with(0,50).and_return(@items[0..49])
        @populr.images.should_receive(:get_restful_model_collection).with(50,50).and_return(@items[50..59])
        @populr.images.range(0,100).count.should == 60
      end

      it "should return early if a request for a chunk returns 0 rows" do
        @populr.images.should_receive(:get_restful_model_collection).with(0,50).and_return(@items[0..49])
        @populr.images.should_receive(:get_restful_model_collection).with(50,50).and_return([])
        @populr.images.range(0,100).count.should == 50
      end
    end

    context "when an offset is provided" do
      it "should return results from that offset forward" do
        @populr.images.should_receive(:get_restful_model_collection).with(100,50).and_return(@items[100..149])
        @populr.images.should_receive(:get_restful_model_collection).with(150,50).and_return(@items[150..199])
        @populr.images.should_receive(:get_restful_model_collection).with(200,50).and_return([])
        @populr.images.range(100, 200).should == @items[100..200]
      end
    end
  end

end

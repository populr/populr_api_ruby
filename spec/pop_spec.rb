::ENV['RACK_ENV'] = 'test'
require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Pop' do
  before (:each) do
    @api = Populr.new('key')
  end

  describe "#initialize" do
    it "should accept an API connection followed by a template" do
      template = Template.new(@api)
      template.stub(:api_regions).and_return([])
      template.stub(:api_tags).and_return([])
      template._id = '123'
      pop = Pop.new(template)
      pop.template_id.should == '123'
      pop.instance_variable_get('@_api').should == @api
    end

    it "should accept a RestfulModelCollection as a parent" do
      pop = Pop.new(@api.pops)
      pop.template_id.should == nil
      pop.instance_variable_get('@_api').should == @api
    end

  end

  describe "#inflate" do
    it "should create a tracer collection whose _parent is set so the tracer's path returns the full nested path" do
      pop = Pop.new(@api.pops)
      pop.inflate(JSON.parse("{\"_id\":\"5107089add02dcaecc000003\",\"created_at\":\"2013-01-28T23:24:10Z\",\"domain\":\"generic\",\"name\":\"Untitled\",\"password\":null,\"slug\":\"\",\"tracers\":[{\"_id\":\"5109b5e0dd02dc5976000001\",\"created_at\":\"2013-01-31T00:08:00Z\",\"name\":\"Facebook\"},{\"_id\":\"5109b5f5dd02dc4c43000002\",\"created_at\":\"2013-01-31T00:08:21Z\",\"name\":\"Twitter\"}],\"published_pop_url\":\"http://group3.lvh.me\",\"unpopulated_api_tags\":[],\"unpopulated_api_regions\":[],\"label_names\":[]}"))
      pop.tracers.path.should == "/pops/#{pop._id}/tracers/"
    end
  end

  describe "#path_for_model" do
    it "should lowercase the classname and pluralize it to create the path" do
      pop = Pop.new(@api)
      pop._id = '123'
      pop.path.should == '/pops/123'
    end
  end

  describe "#publish!" do
    before (:each) do
      @pop = Pop.new(@api)
      @pop.inflate(JSON.parse("{\"_id\":\"5107089add02dcaecc000003\",\"created_at\":\"2013-01-28T23:24:10Z\",\"domain\":\"generic\",\"name\":\"Untitled\",\"password\":null,\"slug\":\"\",\"tracers\":[{\"_id\":\"5109b5e0dd02dc5976000001\",\"created_at\":\"2013-01-31T00:08:00Z\",\"name\":\"Facebook\"},{\"_id\":\"5109b5f5dd02dc4c43000002\",\"created_at\":\"2013-01-31T00:08:21Z\",\"name\":\"Twitter\"}],\"published_pop_url\":\"\",\"unpopulated_api_tags\":[],\"unpopulated_api_regions\":[],\"label_names\":[]}"))

      @result = double('result')
      @result.stub(:code).and_return(200)
      RestClient.stub(:post).and_yield("{\"_id\":\"5107089add02dcaecc000003\",\"created_at\":\"2013-01-28T23:24:10Z\",\"domain\":\"generic\",\"name\":\"Untitled\",\"password\":null,\"slug\":\"\",\"tracers\":[{\"_id\":\"5109b5e0dd02dc5976000001\",\"created_at\":\"2013-01-31T00:08:00Z\",\"name\":\"Facebook\"},{\"_id\":\"5109b5f5dd02dc4c43000002\",\"created_at\":\"2013-01-31T00:08:21Z\",\"name\":\"Twitter\"}],\"published_pop_url\":\"http://group3.lvh.me\",\"unpopulated_api_tags\":[],\"unpopulated_api_regions\":[],\"label_names\":[]}", '', @result)
    end

    it "should call update with the publish action" do
      @pop.should_receive(:update).with('POST', 'publish')
      @pop.publish!
    end

    it "should return the pop" do
      @pop.publish!.should == @pop
    end

    it "should set the published_pop_url" do
      @pop.published_pop_url.should be_empty
      @pop.publish!
      @pop.published_pop_url.should_not be_empty
    end
  end


  describe "#unpublish!" do
    before (:each) do
      @pop = Pop.new(@api)
      @pop.inflate(JSON.parse("{\"_id\":\"5107089add02dcaecc000003\",\"created_at\":\"2013-01-28T23:24:10Z\",\"domain\":\"generic\",\"name\":\"Untitled\",\"password\":null,\"slug\":\"\",\"tracers\":[{\"_id\":\"5109b5e0dd02dc5976000001\",\"created_at\":\"2013-01-31T00:08:00Z\",\"name\":\"Facebook\"},{\"_id\":\"5109b5f5dd02dc4c43000002\",\"created_at\":\"2013-01-31T00:08:21Z\",\"name\":\"Twitter\"}],\"published_pop_url\":\"http://group3.lvh.me\",\"unpopulated_api_tags\":[],\"unpopulated_api_regions\":[],\"label_names\":[]}"))

      @result = double('result')
      @result.stub(:code).and_return(200)
      RestClient.stub(:post).and_yield("{\"_id\":\"5107089add02dcaecc000003\",\"created_at\":\"2013-01-28T23:24:10Z\",\"domain\":\"generic\",\"name\":\"Untitled\",\"password\":null,\"slug\":\"\",\"tracers\":[{\"_id\":\"5109b5e0dd02dc5976000001\",\"created_at\":\"2013-01-31T00:08:00Z\",\"name\":\"Facebook\"},{\"_id\":\"5109b5f5dd02dc4c43000002\",\"created_at\":\"2013-01-31T00:08:21Z\",\"name\":\"Twitter\"}],\"published_pop_url\":\"\",\"unpopulated_api_tags\":[],\"unpopulated_api_regions\":[],\"label_names\":[]}", '', @result)
    end

    it "should call update with the unpublish action" do
      @pop.should_receive(:update).with('POST', 'unpublish')
      @pop.unpublish!
    end

    it "should return the pop" do
      @pop.unpublish!.should == @pop
    end

    it "should set the published_pop_url" do
      @pop.published_pop_url.empty?.should == false
      @pop.unpublish!
      @pop.published_pop_url.empty?.should == true
    end
  end


  describe "Populating Assets and Regions" do
    before (:each) do
      @pop = Pop.new(@api)
      @pop.inflate(JSON.parse("{\"_id\":\"5107089add02dcaecc000003\",\"created_at\":\"2013-01-28T23:24:10Z\",\"domain\":\"generic\",\"name\":\"Untitled\",\"password\":null,\"slug\":\"\",\"tracers\":[{\"_id\":\"5109b5e0dd02dc5976000001\",\"created_at\":\"2013-01-31T00:08:00Z\",\"name\":\"Facebook\"},{\"_id\":\"5109b5f5dd02dc4c43000002\",\"created_at\":\"2013-01-31T00:08:21Z\",\"name\":\"Twitter\"}],\"published_pop_url\":\"http://group3.lvh.me\",\"unpopulated_api_tags\":[\"tag1\"],\"unpopulated_api_regions\":[\"region1\"],\"label_names\":[]}"))

      @asset = double('asset')
      @asset.stub(:_id).and_return('asset_id')
    end

    describe "#populate_region" do
      context "when a single asset is provided" do
        it "should add the ID of the provided asset to the newly_populated_regions hash" do
          @pop.populate_region('region1', @asset)
          @pop.newly_populated_regions['region1'].should == ['asset_id']
        end
      end

      context "when an array of assets is provided" do
        it "should add the IDs of the provided assets to the newly_populated_regions hash" do
          @pop.populate_region('region1', [@asset])
          @pop.newly_populated_regions['region1'].should == ['asset_id']
        end
      end

      it "should remove the region identifier from the list of unpopulated regions" do
        @pop.unpopulated_api_regions.include?('region1').should == true
        @pop.populate_region('region1', @asset)
        @pop.unpopulated_api_regions.include?('region1').should == false
      end
    end


    describe "#has_unpopulated_region" do
      it "should return true if the region identifier is unpopulated" do
        @pop.has_unpopulated_region('region1').should == true
      end

      it "should return false otherwise" do
        @pop.has_unpopulated_region('region2').should == false
      end
    end


    describe "#populate_tag" do
      it "should add the identifier -> value pair to the newly populated tags array" do
        @pop.populate_tag('tag1', 'content')
        @pop.newly_populated_tags.should == {'tag1' => 'content'}
      end

      it "should remove the identifier from the unpopulated_api_tags array" do
        @pop.unpopulated_api_tags.include?('tag1').should == true
        @pop.populate_tag('tag1', 'content')
        @pop.unpopulated_api_tags.include?('tag1').should == false
      end
    end

    describe "#has_unpopulated_tag" do
      it "should return true if the tag identifier is unpopulated" do
        @pop.has_unpopulated_tag('tag1').should == true
      end

      it "should return false otherwise" do
        @pop.has_unpopulated_tag('tag2').should == false
      end
    end
  end

end
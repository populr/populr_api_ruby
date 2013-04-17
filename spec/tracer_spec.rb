::ENV['RACK_ENV'] = 'test'
require File.join(File.dirname(__FILE__), 'spec_helper')
require 'rack/test'

describe 'Pop' do
  include Rack::Test::Methods
  before (:each) do
    @api = Populr.new('key')
    @tracer = Tracer.new(@api)
    @tracer.inflate(JSON.parse("{\"code\":\"tc\",\"name\":\"Twitter\",\"notify_on_open\":false,\"analytics\":{\"views\":6,\"clicks\":24,\"links\":{\"http://www.populr.me/\":{\"clicks\":4}},\"assets\":{\"empty_region\":{},\"unnamed_region_0\":{\"132213ae12bc1312\":{\"clicks\":10}},\"my_image_region\":{\"132213ae21f4812f\":{\"clicks\":10},\"f48121f48121f421\":{\"clicks\":3}}}}}"))
  end


  describe "#views" do
    it "should retrieve the total views from analytics" do
      @tracer.views.should == 6
    end
  end

  describe "#clicks" do
    it "should retrieve the total clicks from analytics" do
      @tracer.clicks.should == 24
    end
  end

  describe "#clicks_for_region" do
    it "should sum the clicks for all assets in the region" do
      @tracer.clicks_for_region('my_image_region').should == 13
    end

    it "should return 0 if the region does not exist" do
      @tracer.clicks_for_region('nonexistent_region').should == 0
    end

    it "shoud return 0 if the region has no assets" do
      @tracer.clicks_for_region('empty_region').should == 0
    end

    it "should return 0 if the assets section of analytics is not present" do
      @tracer.inflate(JSON.parse("{\"code\":\"tc\",\"name\":\"Twitter\",\"notify_on_open\":false,\"analytics\":{\"views\":6,\"clicks\":24,\"links\":{\"http://www.populr.me/\":{\"clicks\":4}}}}"))
      @tracer.clicks_for_region('my_image_region').should == 0
    end
  end

  describe "#clicks_for_link" do
    it "should return the analytics clicks value if the link exists" do
      @tracer.clicks_for_link('http://www.populr.me/').should == 4
    end

    it "should return 0 if the link does not exist" do
      @tracer.clicks_for_link('http://www.nonexistent.com/').should == 0
    end

    it "should return 0 if the link hash is not present" do
      @tracer.inflate(JSON.parse("{\"code\":\"tc\",\"name\":\"Twitter\",\"notify_on_open\":false,\"analytics\":{\"views\":6,\"clicks\":24}}"))
      @tracer.clicks_for_link('http://www.populr.com/').should == 0
    end
  end

  describe "#clicks_for_asset" do
    it "should scan through the regions in the analytics hash and return the asset clicks" do
      @tracer.clicks_for_asset('132213ae21f4812f').should == 10
    end

    it "should return 0 if the assets section of analytics is not present" do
      @tracer.inflate(JSON.parse("{\"code\":\"tc\",\"name\":\"Twitter\",\"notify_on_open\":false,\"analytics\":{\"views\":6,\"clicks\":24,\"links\":{\"http://www.populr.me/\":{\"clicks\":4}}}}"))
      @tracer.clicks_for_asset('132213ae21f4812f').should == 0
    end

    it "should return 0 if there is no matching asset" do
      @tracer.clicks_for_asset('asd').should == 0
    end

    it "should accept an asset object as a parameter" do
      asset = ImageAsset.new(@api, nil)
      asset._id = '132213ae21f4812f'
      @tracer.clicks_for_asset(asset).should == 10
    end

    it "should accept an asset id as a parameter" do
      @tracer.clicks_for_asset('132213ae21f4812f').should == 10
    end
  end

  describe "#enable_webhook" do
    it "should set the webhook and enable notify_on_open" do
      @webhook = 'http://mycallback.com'

      @tracer.notify_on_open.should == false
      @tracer.enable_webhook(@webhook)
      @tracer.notify_on_open.should == true
      @tracer.notify_webhook.should == @webhook
    end
  end

  describe "#code=" do
    it "should only allow the tracer code to be set if there isn't a value" do
      @tracer = Tracer.new(@api)
      @tracer.code.should == nil
      @tracer.code = 'as'

      lambda {
        @tracer.code = 'bb'
      }.should raise_error(Tracer::CodeCannotBeModified)
    end
  end
end

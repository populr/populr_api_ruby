::ENV['RACK_ENV'] = 'test'
require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Populr' do
  before (:each) do
    @api_key = 'UXXMOCJW-BKSLPCFI-UQAQFWLO'
    @populr = Populr.new(@api_key)
  end

  describe '#templates' do
    it "should return a model collection" do
      @populr.templates.is_a?(RestfulModelCollection).should == true
    end
  end


  describe '#pops' do
    it "should return a model collection" do
      @populr.templates.is_a?(RestfulModelCollection).should == true
    end
  end

  describe "#url_for_path" do
    it "should return the url for a provided path" do
      @populr.url_for_path('/wobble').should == "https://#{@populr.api_key}:@api.populr.me/v0/wobble"
    end
  end

  describe "#self.interpret_response" do
    before (:each) do
      @result = double('result')
      @result.stub(:code).and_return(200)
    end

    context "when an expected_class is provided" do
      context "when the server responds with a 200 but unknown, invalid body" do
        it "should raise an UnexpectedResponse" do
          lambda {
            Populr.interpret_response(@result, "I AM NOT JSON", {:expected_class => Array})
          }.should raise_error(Populr::UnexpectedResponse)
        end
      end

      context "when the server responds with JSON that does not represent an array" do
        it "should raise an UnexpectedResponse" do
          @result.stub(:code).and_return(500)
          lambda {
            Populr.interpret_response(@result, "{\"_id\":\"5107089add02dcaecc000003\",\"created_at\":\"2013-01-28T23:24:10Z\",\"domain\":\"generic\",\"name\":\"Untitled\",\"password\":null,\"slug\":\"\",\"tracers\":[{\"_id\":\"5109b5e0dd02dc5976000001\",\"created_at\":\"2013-01-31T00:08:00Z\",\"name\":\"Facebook\"},{\"_id\":\"5109b5f5dd02dc4c43000002\",\"created_at\":\"2013-01-31T00:08:21Z\",\"name\":\"Twitter\"}],\"published_pop_url\":\"http://group3.lvh.me\",\"unpopulated_api_tags\":[],\"unpopulated_api_regions\":[],\"label_names\":[]}", {:expected_class => Array})
          }.should raise_error(Populr::UnexpectedResponse)
        end
      end
    end

    context "when the server responds with a 403" do
      it "should raise AccessDenied" do
        @result.stub(:code).and_return(403)
        lambda {
          Populr.interpret_response(@result, '')
        }.should raise_error(Populr::AccessDenied)
      end
    end

    context "when the server responds with a 404" do
      it "should raise ResourceNotFound" do
        @result.stub(:code).and_return(404)
        lambda {
          Populr.interpret_response(@result, '')
        }.should raise_error(Populr::ResourceNotFound)
      end
    end

    context "when the server responds with another status code" do
      it "should raise an UnexpectedResponse" do
        @result.stub(:code).and_return(500)
        lambda {
          Populr.interpret_response(@result, '')
        }.should raise_error(Populr::UnexpectedResponse)
      end
    end

  end

end

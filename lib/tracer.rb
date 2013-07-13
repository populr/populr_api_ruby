require 'restful_model'

class Tracer < RestfulModel

  class CodeCannotBeModified < StandardError; end

  attr_accessor :name
  attr_accessor :code
  attr_accessor :notify_on_open
  attr_accessor :notify_webhook
  attr_accessor :analytics

  def views
    return analytics["views"].to_i
  end

  def clicks
    return analytics["clicks"].to_i
  end

  def clicks_for_region(region_id)
    return 0 unless analytics["assets"] && analytics["assets"][region_id]

    clicks = 0
    for key, asset in analytics["assets"][region_id]
      clicks += asset["clicks"].to_i
    end
    clicks
  end

  def clicks_for_link(link)
    return 0 unless analytics["links"] && analytics["links"][link]
    return analytics["links"][link]["clicks"].to_i
  end

  def clicks_for_asset(asset_or_id)
    return 0 unless analytics["assets"]
    asset_id = asset_or_id.is_a?(Asset) ? asset_or_id._id : asset_or_id

    for region, assets in analytics["assets"]
      for key, asset in assets
        return asset["clicks"].to_i if key == asset_id
      end
    end
    return 0
  end

  def code=(c)
    raise CodeCannotBeModified.new if code && c != code
    @code = c
  end

  def enable_webhook(url)
    self.notify_on_open = true
    self.notify_webhook = url
  end

end
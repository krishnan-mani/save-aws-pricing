require 'mongo'
require 'json'

class SaveAWSPriceList

  def initialize(db_url)
    @client = Mongo::Client.new(db_url)
  end

  def save(offer_index_filename)
    offer_index_json = JSON.parse(File.read(offer_index_filename))

    offerCode = offer_index_json["offerCode"]
    version = offer_index_json["version"]
    skus = offer_index_json["products"].keys
    skus.each do |sku|
      sku_doc = {
          "sku" => sku,
          "version" => version,
          "offerCode" => offerCode
      }
      @client[:skus].insert_one(sku_doc)
    end

  end

end
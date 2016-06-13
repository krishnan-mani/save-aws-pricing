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
    skus = offer_index_json["products"]
    save_skus(skus, offerCode, version)

    terms = offer_index_json["terms"]
    save_terms(terms, offerCode, version)
  end

  def save_terms(terms, offerCode, version)
    terms.each_key do |term|
      term_doc = {
          "_id" => "#{version}:#{offerCode}#{term}",
          "offerCode" => offerCode,
          "version" => version,
          "term": term
      }
      @client[:terms].insert_one(term_doc)
    end
  end

  def save_skus(skus, offerCode, version)
    skus.each_key do |sku|
      sku_doc = {
          "_id": "#{version}:#{sku}",
          "offerCode" => offerCode,
          "version" => version,
          "sku" => sku,
          "productFamily" => skus[sku]["productFamily"],
          "attributes" => skus[sku]["attributes"]
      }
      @client[:skus].insert_one(sku_doc)
    end
  end

end
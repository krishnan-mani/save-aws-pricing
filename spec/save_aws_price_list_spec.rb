require 'json'
require 'mongo'

require_relative '../lib/save_aws_price_list'

RSpec.describe "save AWS price list from offer-index file" do

  db_url = "mongodb://127.0.0.1:27017/test_save_aws_pricing"
  offer_index_filename = File.join(File.dirname(__FILE__), 'resources', 'AmazonRoute53_offer-index.json')
  offer_index_json = JSON.parse(File.read(offer_index_filename))
  _offer_code = offer_index_json["offerCode"]
  _version = offer_index_json["version"]

  before(:each) do
    Mongo::Client.new(db_url).database.drop
  end

  it "saves offer code, and skus by version for the service" do

    first_sku_id = offer_index_json["products"].keys.first
    first_sku = offer_index_json["products"][first_sku_id]
    sku_count = offer_index_json["products"].keys.count

    SaveAWSPriceList.new(db_url).save(offer_index_filename)

    db_client = Mongo::Client.new(db_url)
    expect((db_client)[:skus].count(:version => _version, :offerCode => _offer_code)).to be sku_count

    found_sku = db_client[:skus].find(:version => _version, :sku => first_sku_id).limit(1).first
    expect(found_sku["offerCode"]).to eq(_offer_code)
    expect(found_sku["productFamily"]).to eq(first_sku["productFamily"])
    expect(found_sku["attributes"]).to eq(first_sku["attributes"])
  end

  it "saves offer code, and terms by version for the service" do
    terms = offer_index_json["terms"].keys
    some_term = terms.first
    SaveAWSPriceList.new(db_url).save(offer_index_filename)

    db_client = Mongo::Client.new(db_url)
    expect(db_client[:terms].count(:version => _version, :offerCode => _offer_code)).to be terms.count
    found_term = db_client[:terms].find(:version => _version, :offerCode => _offer_code, :term => some_term).limit(1).first["term"]
    expect(found_term).to eq some_term
  end

  it "saves offer code, and offer term codes for sku by version for the service" do
    terms = offer_index_json["terms"]
    offer_term_codes_by_sku = []
    terms.each_key do |term|
      terms[term].each_key do |sku|
        offer_term_codes_by_sku << terms[term][sku]
      end
    end

    SaveAWSPriceList.new(db_url).save(offer_index_filename)

    db_client = Mongo::Client.new(db_url)
    expect(db_client[:offer_term_codes_by_sku].count(:version => _version, :offerCode => _offer_code)).to be offer_term_codes_by_sku.count

    some_otc_by_sku = offer_term_codes_by_sku.first.values.first
    found_otc_by_sku = db_client[:offer_term_codes_by_sku].find(:version => _version, :offerCode => _offer_code, :sku => some_otc_by_sku["sku"], :offerTermCode => some_otc_by_sku["offerTermCode"]).limit(1).first
    expect(found_otc_by_sku["effectiveDate"]).to eq(some_otc_by_sku["effectiveDate"])
  end

end
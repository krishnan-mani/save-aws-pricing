require 'json'
require 'mongo'

require_relative '../lib/save_aws_price_list'

RSpec.describe "save AWS price list from offer-index file" do

  db_url = "mongodb://127.0.0.1:27017/test_save_aws_pricing"
  offer_index_filename = File.join(File.dirname(__FILE__), 'resources', 'AmazonRoute53_offer-index.json')
  offer_index_json = JSON.parse(File.read(offer_index_filename))

  before(:each) do
    Mongo::Client.new(db_url).database.drop
  end

  it "saves offer code, sku by version for the service" do
    _offer_code = offer_index_json["offerCode"]
    _version = offer_index_json["version"]

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

  it "saves offer code, terms and offer term code by version for the service" do
    :pending
  end

end
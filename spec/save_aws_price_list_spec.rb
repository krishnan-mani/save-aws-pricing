require 'json'
require 'mongo'

require_relative '../lib/save_aws_price_list'

RSpec.describe "save AWS price list" do

  db_url = "mongodb://127.0.0.1:27017/test_save_aws_pricing"

  before(:each) do
    Mongo::Client.new(db_url).database.drop
  end

  it "saves offer code, sku, term type, offer term code, rate code by version for the service as specified in the offer-index file" do

    offer_index_filename = File.join(File.dirname(__FILE__), 'resources', 'AmazonRoute53_offer-index.json')
    offer_index_json = JSON.parse(File.read(offer_index_filename))
    _offer_code = offer_index_json["offerCode"]
    _version = offer_index_json["version"]

    SaveAWSPriceList.new(db_url).save(offer_index_filename)

    db_client = Mongo::Client.new(db_url)
    expect(db_client[:skus].find(:version => _version).count).to be > 0
  end

end
require 'mongo'

require_relative 'lib/save_aws_price_list'


# Example: $ DATABASE_URL="mongodb://127.0.0.1:27017/test_save_aws_pricing" rake clear_data
desc 'Clear database'
task :clear_data do
  db_url = ENV["DATABASE_URL"]
  raise "Database configuration not specified as DATABASE_URL environment variable" unless db_url

  Mongo::Client.new(db_url).database.drop
end

# Example: $ DATABASE_URL="mongodb://127.0.0.1:27017/test_save_aws_pricing" rake "save_price_list[./spec/resources/]"
desc 'Save price list'
task :save_price_list, :offer_index_file_location do |t, args|
  db_url = ENV["DATABASE_URL"]
  raise "Database configuration not specified as DATABASE_URL environment variable" unless db_url

  offer_index_files = Dir[File.join(args.offer_index_file_location, "*_offer-index.json")]
  p offer_index_files

  offer_index_files.each do |file_location|
    SaveAWSPriceList.new(db_url).save(file_location)
  end
end
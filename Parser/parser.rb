require 'rubygems'
require 'mongo'

include Mongo

client = MongoClient.new('home', 27017)
db     = client['results']

puts "digraph {"
db.collection_names.each do |coll|
	next if coll === "system.indexes"
	data = db[coll].find.sort(:timestamp => :desc).next
	data.each do |server, ping|
		next if server === "_id"
		next if server === "timestamp"
		puts "\t#{coll} -> #{server} [label = \"#{ping}\"];"
	end
end
puts "}"

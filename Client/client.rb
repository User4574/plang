require 'rubygems'
require 'mongo'

include Mongo

THIS = "servera"
settings = nil
slock = false

threads = {}

client	= MongoClient.new('home', 27017)
cdb		= client['configs']
rdb		= client['results']
ccoll	= cdb[THIS]
rcoll	= rdb[THIS]

ccoll.find.each do |doc|
	settings = doc
end

threads["pingthread"] = Thread.new do loop do
	unless slock
		slock = true
		results = {"timestamp" => Time.now.to_i}
		settings["neighbours"].each do |neighbour|
			pingtime = %x[ping -c1 #{neighbour}][/time=(.*?) ms/, 1]
			results.merge!({neighbour => pingtime})
		end
		rcoll.insert(results)
		slock = false
		sleep(settings["pinginterval"])
	end
end end

threads["threadupdater"] = Thread.new do loop do
	unless slock
		slock = true
		ccoll.find.each do |doc|
			settings = doc
		end
		slock = false
		sleep(settings["configttl"])
	end
end end

threads.each do |name, thr|
	thr.join
end

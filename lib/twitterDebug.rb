require 'lib/twitterConnection'
require 'json'
require 'date'

module TwitterAPI

	class TwitterDebug

		attr_accessor :twitterConnection

		# ShowRateLimit
		# -> Affiche les nombres de requêtes restantes
		# PARAMS : No
		# RETURN : No
		def self.ShowRateLimit
			@twitterConnection = TwitterAPI::TwitterConnection.new
			rateLimit = JSON.parse(@twitterConnection.getRateLimit().body)


			rateLimit["resources"].each do |resource, value|
				value.each do |type, value|
					PrintRateLimit(type, value["remaining"], value["limit"], value["reset"])
				end
			end
		end

	## PRIVATE METHODS
	private

		# PrintRateLimit
		# -> Affiche les nombres de requêtes restantes
		# PARAMS : 
			# type : type de requêtes (ex : /users/show/ ou /statuses/user_timeline/)
			# remaining : nombre de requêtes restants
			# limit : nombre de requêtes maximal
			# reset : date du prochain reset en Timestomp
		# RETURN : No
		def self.PrintRateLimit(type, remaining, limit, reset)
			puts "#{type} : #{remaining}/#{limit} restants - Reset : #{Time.at(reset).to_time}"
		end
	end
end


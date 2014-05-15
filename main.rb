$: << "."

require 'timeout'
require 'lib/unisocprinter'
require 'lib/twitterDebug'

def executeCommand(command)
	commands = command.downcase.split(" ")
	case commands[0] # Correspond à la première commande : st (showTwitter), h (help)
		when "twitter", "t"
		case commands[1]
			when "ratelimit", "rl"
				TwitterAPI::TwitterDebug.ShowRateLimit
			when "timeline", "t"
				UniSoc::UniSocPrinter.PrintTwitterTimeline
			when "user", "u"
				UniSoc::UniSocPrinter.PrintTwitterUser commands[2]
		end

		when "help", "h"
			UniSoc::UniSocPrinter.PrintHelp

		when "q"
			exit(0)

	end
end

printer = UniSoc::UniSocPrinter.new

=begin
parsed = JSON.parse(tc.getTweetsFromUser('aamulumi', 10).body)

parsed.reverse.each do |parse|
	puts "\t[TWEET]-> write by #{parse["user"]["name"]} the #{parse["created_at"]} - RT : #{parse["retweet_count"]} - <3 : #{parse["favorite_count"]}"
	puts "#{parse["text"]}"
end


when "showTwitter rateLimit" || "st rl"
			TwitterAPI::TwitterDebug.ShowRateLimit
		when "showTwitter timeline" || "st t"
			UniSoc::UniSocPrinter.PrintTwitterTimeline
		when "showTwitter user" || "st u"
			UniSoc::UniSocPrinter.Print
		when "help" || "h"
			UniSoc::UniSocPrinter.PrintHelp

=end
tmp = ""

begin
	begin
		puts "[INFO] Rafraîchissement de la timeline"
		
		UniSoc::UniSocPrinter.PrintRecentTimeline()
		status = Timeout::timeout(60) {
			while true
				print "> "
				tmp = gets.chomp
				executeCommand(tmp)
			end
		}

	rescue Timeout::Error
		print "\r"
	end

end while true





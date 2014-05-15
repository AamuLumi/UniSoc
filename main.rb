$: << "."

require 'timeout'
require 'lib/uniSocPrinter'
require 'lib/twitterDebug'

# executeCommand
# -> Execute la commande spécifiée
# PARAMS :
	# command : la commande à exécuter
# RETURN : No
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
			when "mention", "m"
				UniSoc::UniSocPrinter.PrintTwitterMentionTimeline
		end

		when "help", "h"
			UniSoc::UniSocPrinter.PrintHelp

		when "q"
			exit(0)
	end
end

tmpKeyboard = ""

# On initialise UniSocPrinter
UniSoc::UniSocPrinter.Init("unknown")

begin
	begin
		puts "[INFO] Rafraîchissement de la timeline"
		
		# On affiche les données de Twitter
		UniSoc::UniSocPrinter.PrintTwitterDatas

		# Permet de rentrer des commandes et d'obtenir un rafraîchissement toutes les 60 secondes
		status = Timeout::timeout(60) {
			while true
				print "> "
				tmpKeyboard = gets.chomp
				executeCommand(tmpKeyboard)
			end
		}

	# Quand on dépasse les 60 secondes, on supprime le caractère d'entrée au clavier
	rescue Timeout::Error
		print "\r"
	end

end while true





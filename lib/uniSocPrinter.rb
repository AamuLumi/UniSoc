require 'lib/twitterConnection'
require 'json'

module UniSoc

	class UniSocPrinter

		attr_reader :twitterConnection, :lastTweetID, :tweets, :commands, :mentions, :user, :lastMentionID

		## Commandes acceptées par le programme avec leurs descriptions
		@commands = { 
			"[t] Twitter" => {
				"[rl] ratelimit" => "Affiche le nombre de requêtes restantes",
				"[t] timeline" => "Affiche la timeline",
				"[m] mention" => "Affiche les mentions",
				"[u] user <username>" => "Affiche les informations sur l'utilisateur"
			},
			"[q] quit" => "Quitte l'application"
		}

		def self.Init (user)
			@@user = user
			@@twitterConnection = TwitterAPI::TwitterConnection.new
			@@lastTweetID = 0
			@@tweets = nil
			@@mentions = nil
		end

		## CLASS METHODS

		def self.PrintTwitterDatas
			LoadAndPrintTimeline()
			LoadAndPrintMentionTimeline()
		end

		# PrintTwitterTimeline
		# -> Affiche la timeline Twitter
		# PARAMS : No
		# RETURN : No
		def self.PrintTwitterTimeline
			if (@@tweets != nil)
				@@tweets.reverse.each do |tweet|
					UniSocPrinter.PrintTweet(tweet["user"]["name"], tweet["created_at"], tweet["retweet_count"], tweet["favorite_count"], tweet["text"])
				end
			else
				puts "Aucun tweet trouvé"
			end
		end

		# PrintTwitterMentionTimeline
		# -> Affiche la timeline des mentions Twitter
		# PARAMS : No
		# RETURN : No
		def self.PrintTwitterMentionTimeline
			if (@@mentions != nil)
				@@mentions.reverse.each do |tweet|
					UniSocPrinter.PrintMention(tweet["user"]["name"], tweet["created_at"], tweet["retweet_count"], tweet["favorite_count"], tweet["text"])
				end
			else
				puts "Aucune mention trouvé"
			end
		end

		# PrintTwitterUser
		# -> Affiche les informations sur un utilisateur Twitter
		# PARAMS : user : l'utilisateur à chercher
		# RETURN : No
		def self.PrintTwitterUser(user)
			user = LoadUser(user)

			if (user != nil)
				PrintUserInfos(user["name"], user["screen_name"], user["location"], user["description"], user["url"], user["followers_count"], user["friends_count"],
					user["listed_count"], user["favourites_count"], user["created_at"], user["statuses_count"])
			else
				puts "Aucun utilisateur trouvé"
			end
		end

		# PrintHelp
		# -> Affiche l'aide du programme'
		# PARAMS : No
		# RETURN : No
		def self.PrintHelp
			puts "[AIDE] UniSoc"
			@commands.each do |command, value|
				if (value.class == Hash)
					puts "\t#{command} :"
					value.each do |command, value|
						puts "\t\t- #{command} => #{value}"
					end
				else	
					puts "\t- #{command} => #{value}"
				end

				puts "\n"
			end
		end

		# LoadAndPrintTimeline
		# -> Récupère les données récentes et affiche les nouveaux tweets
		# PARAMS : No
		# RETURN : No
		def self.LoadAndPrintTimeline
			# Initialisation
			if (@@tweets == nil)
				# Si le chargement des tweets a marché
				if (LoadTimeline())
					# On inverse l'ordre des tweets pour les afficher du plus ancien au plus récent
					@@tweets.reverse.each do |parse|
						PrintTweet(parse["user"]["name"], parse["created_at"], parse["retweet_count"], parse["favorite_count"], parse["text"])
					end
				end
			else 
				# On charge les nouveaux tweets
				newTweets = LoadRecentTweets()
				if (newTweets != nil)
					newTweets.reverse.each do |parse|
						PrintTweet(parse["user"]["name"], parse["created_at"], parse["retweet_count"], parse["favorite_count"], parse["text"])
					end
					# On stocke les nouveaux tweets
					@@tweets = newTweets + @@tweets
					@@lastTweetID = @@tweets[0]["id"]
				end
			end
		end

		# LoadAndPrintMentions
		# -> Récupère les mentions récentes et les affiche
		# PARAMS : No
		# RETURN : No
		def self.LoadAndPrintMentionTimeline
			# Initialisation
			if (@@mentions== nil)
				# On ne fait que charger les mentions, on ne les affiche pas directement
				LoadMentions()
			else 
				# On charge les nouveaux tweets
				newMentions = LoadRecentMentions()
				if (newMentions != nil)
					newMentions.reverse.each do |parse|
						PrintMention(parse["user"]["name"], parse["created_at"], parse["retweet_count"], parse["favorite_count"], parse["text"])
					end
					# On stocke les nouveaux tweets
					@@mentions = newMentions + @@mentions
					@@lastMentionID = @@mentions[0]["id"]
				end
			end
		end

	## PRIVATE METHODS
	private

		# PrintTweet
		# -> Affiche un tweet
		# PARAMS : 
			# writer : l'auteur du tweet
			# date : la date du tweet
			# rt_count : le nombre de retweets
			# f_cout : le nombre de favoris
			# text : le contenu du tweet
		# RETURN : No
		def self.PrintTweet (writer, date, rt_count, f_count, text)
			puts "\t################### TWEET ###################\n\t## -> write by #{writer} the #{date} - RT : #{rt_count} - <3 : #{f_count}"
			puts "#{text}\n\n"
		end

		# PrintMention
		# -> Affiche un tweet
		# PARAMS : 
			# writer : l'auteur du tweet
			# date : la date du tweet
			# rt_count : le nombre de retweets
			# f_cout : le nombre de favoris
			# text : le contenu du tweet
		# RETURN : No
		def self.PrintMention (writer, date, rt_count, f_count, text)
			puts "\t¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤ MENTION ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤\n\t¤¤ -> write by #{writer} the #{date} - RT : #{rt_count} - <3 : #{f_count}"
			puts "#{text}\n\n"
		end

		# PrintUserInfos
		# -> Affiche les informations d'un utilisateur
		# PARAMS : 
			# name : le nom de l'utilisateur
			# screen_name : @username 
			# location : le lieu d'habitation
			# description : la description de l'utilisateur
			# url : url du site de l'utilisateur
			# followers_count : nombre de followers
			# friends_count : nombre d'amis
			# listed_count : ?
			# favourites_count : nombre de favoris
			# statuses_count : nombre de tweets de l'utilisateur
			# created_at : date de création du compte
		# RETURN : No
		def self.PrintUserInfos(name, screen_name, location, description, url, followers_count, friends_count, listed_count, favourites_count, created_at, statuses_count)
			puts "\t()()()()()()()()()() USER ()()()()()()()()()()\n"
			puts "\t#{name} - @#{screen_name} - Who? : #{description} - Where? : #{location}"
			puts "\tOn the Internet : #{url} - First time on Twitter : #{created_at}"
			puts "\tTweets : #{statuses_count} - Followers : #{followers_count} - Friends : #{friends_count} - Listed : #{listed_count} - <3 : #{favourites_count}"
		end

		# LoadTimeline
		# -> Récupère les 10 premiers tweets de la timeline
		# PARAMS : No
		# RETURN : boolean : true si on a récupérer des tweets, false en cas d'erreur
		def self.LoadTimeline
			tmp = @@twitterConnection.getTimeline(10)
			if (tmp != nil)
				@@tweets = JSON.parse(tmp.body)
				@@lastTweetID = @@tweets[0]["id"]
			end

			return tmp != nil
		end

		# LoadMentions
		# -> Récupère les 10 premières mentions de notre utilisateur
		# PARAMS : No
		# RETURN : boolean : true si on a récupérer des mentions, false en cas d'erreur
		def self.LoadMentions
			tmp = @@twitterConnection.getMentions(10)
			if (tmp != nil)
				@@mentions = JSON.parse(tmp.body)
				@@lastMentionID = @@mentions[0]["id"]
			end

			return tmp != nil
		end

		# LoadRecentTweet
		# -> Récupère les tweets les plus récents (par rapport à nos tweets actuels)
		# PARAMS : No
		# RETURN : boolean : true si on a récupérer des tweets, false en cas d'erreur
		def self.LoadRecentTweets
			tmp = @@twitterConnection.getTweetsSinceID(@@lastTweetID)
			if (tmp != nil)
				return JSON.parse(tmp.body)
			end

			return nil
		end

		# LoadRecentMentions
		# -> Récupère les mentions les plus récents (par rapport à nos mentions actuels)
		# PARAMS : No
		# RETURN : boolean : true si on a récupérer des tweets, false en cas d'erreur
		def self.LoadRecentMentions
			tmp = @@twitterConnection.getMentionsSinceID(@@lastMentionID)
			if (tmp != nil)
				return JSON.parse(tmp.body)
			end

			return nil
		end

		# LoadUser
		# -> Récupère les informations sur un utilisateur
		# PARAMS : No
		# RETURN : boolean : true si on a récupérer des tweets, false en cas d'erreur
		def self.LoadUser(user)
			tmp = @@twitterConnection.getUser(user)
			if (tmp != nil)
				return JSON.parse(tmp.body)
			end

			return nil
		end

		def self.LoadTwittsFromUser(user)
			tmp = @@twitterConnection.getTweetsFromUser(user)
			if (tmp != nil)
				return JSON.parse(tmp.body)
			end

			return nil
		end
	end
end
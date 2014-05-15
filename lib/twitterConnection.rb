require 'simple_oauth'
require 'openssl'
require 'net/http'
require 'net/https'
require 'uri'

require 'lib/twitterDebug'

module TwitterAPI

	class TwitterConnection

		attr_accessor :options

		def initialize
			consumer_key, consumer_secret, token, token_secret = ""

			# Les informations de connexion sont contenus dans le fichier app_informations.txt
			# Il est dans le format suivant :
			#
			# consumer_key xxxxxxxxxxxxxxxxxxx
			# consumer_secret xxxxxxxxxxxxxxxxxxxxx
			# token xxxxxxxxxxxxxxxxxxxxxxxx
			# token_secret xxxxxxxxxxxxxxxxx

			f = File.open("lib/app_informations.txt", "r")
			f.each_line do |line|
				tmp = line.split(" ")
				
				case tmp[0]
				when "consumer_key"
					consumer_key = tmp[1]
				when "consumer_secret"
					consumer_secret = tmp[1]
				when "token"
					token = tmp[1]
				when "token_secret"
					token_secret = tmp[1]
				end
			end
			f.close

			# Options
			@options = {
        		:consumer_key => consumer_key,
       			:consumer_secret => consumer_secret,
				:nonce => OpenSSL::Random.random_bytes(16).unpack('H*')[0],
				:signature_method => 'HMAC-SHA1',
				:timestamp => Time.now.to_i.to_s,
				:token => token,
				:token_secret => token_secret
			}
		end

		# getTweetsFromUser
		# -> Récupère les tweets d'un utilisateur
		# PARAMS : 
			# user : l'utilisateur ciblé
			# nbTweets : le nombre de tweets voulu
		# RETURN : JSON avec les tweets
		def getTweetsFromUser(user, nbTweets)
			url = URI.parse("https://api.twitter.com/1.1/statuses/user_timeline.json?count=#{nbTweets}+&user_screen=#{user}")
			return executeRequest(url)
		end

		# getTimelineForUser
		# -> Récupère la timeline principale
		# PARAMS : 
			# nbTweets : le nombre de tweets voulu
		# RETURN : JSON avec les tweets
		def getTimelineForUser(nbTweets)
			url = URI.parse("https://api.twitter.com/1.1/statuses/home_timeline.json?count=#{nbTweets}");
			return executeRequest(url)
		end

		# getTweetsSinceID
		# -> Récupère les tweets de la timeline principale plus récent que celui dont on donne l'id
		# PARAMS : 
			# id : l'id du tweet le plus récent
		# RETURN : JSON avec les tweets
		def getTweetsSinceID(id)
			url = URI.parse("https://api.twitter.com/1.1/statuses/home_timeline.json?since_id=#{id}");
			return executeRequest(url) 
		end

		# getRateLimit
		# -> Récupère les nombres de requêtes restantes
		# PARAMS : No
		# RETURN : JSON avec les tweets
		def getRateLimit
			url = URI.parse("https://api.twitter.com/1.1/application/rate_limit_status.json?resources=help,users,search,statuses");
			return executeRequest(url) 
		end

		# getUser
		# -> Récupère les informations sur un utilisateur
		# PARAMS : 
			# user : l'utilisateur ciblé
		# RETURN : JSON avec les tweets
		def getUser(user)
			url = URI.parse("https://api.twitter.com/1.1/users/show.json?screen_name=#{user}");
			return executeRequest(url) 
		end

	# PRIVATE METHODS
	private

		# executeRequest
		# -> Execute une requête depuis une URL
		# PARAMS : 
			# url : la requête URL
		# RETURN : JSON avec les informations demandées
		def executeRequest(url)
			# On crée un header avec l'url et les informations de Authorization (cf https://dev.twitter.com/docs/auth/authorizing-request)
			header = SimpleOAuth::Header.new(:get, url, nil, @options)

			# On crée un socket vers le serveur
			http = Net::HTTP.new(url.host, url.port)

			http.set_debug_output($stdout) # Décommenter pour voir les informations de Debug

			# CERTIFICAT NON IMPLEMENTE suite à une erreur
			http.ca_path = "~/ruby/UniSoc/certificates"
			http.verify_mode = OpenSSL::SSL::VERIFY_NONE # VERIFY_PEER POUR SSL Certificate

			http.verify_depth = 9

			# On active le ssl si l'url commence par https
			http.use_ssl = (url.scheme == "https")

			# On crée une requête Get
			req = Net::HTTP::Get.new(url)

			# On ajoute le header
			req['Authorization'] = header.to_s

			# On envoie la requête
			rep = http.request(req)

			# Si notre JSON de retour contient un champs errors
			if (JSON.parse(rep.body).include?("errors"))
				# On affiche l'erreur
				puts "Errors : #{JSON.parse(rep.body)["errors"]}"

				# On affiche aussi les informations sur les nombres de requêtes restants
				TwitterAPI::TwitterDebug.ShowRateLimit

				# On est en erreur, donc on retourne nil
				return nil
			end

			# Tout s'est bien passé, on renvoie le JSON
			return rep
		end
	end
end




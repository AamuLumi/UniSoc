# UniSoc

UniSoc est un client pour les réseaux sociaux. Il va permettre d'unifier tous les réseaux sociaux dans un unique logiciel.

Pour le moment, le travail débute avec l'utilisation de Twitter.

### Spécifications techniques

UniSoc fonctionne avec Ruby (développé sous Ruby 2.1).
Les gems suivantes sont nécessaires :
- [simple_oauth](https://github.com/laserlemon/simple_oauth)


### Fonctionnalités actuelles

#### Twitter

- Lecture de la timeline de l'utilisateur
- Rafrachîssement automatique de la timeline en fonction du nombre de requêtes maximal toléré par Twitter (15 en 15min)
- Consultation d'informations sur un utilisateur
- Consultation des données concernant les nombres de requêtes maximals

### Démarrage

Pour utiliser le logiciel, il est nécessaire d'avoir un compte développeur Twitter.
Il faut ensuite créer une nouvelle application, générer les tokens, et les placer dans un fichier ./lib/app_informations.txt de la façon suivante :

  consumer_key xxxxxxxxxxxxxxxxxxxxxxxx
  consumer_secret xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  token xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  token_secret xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  
Puis on lance le programme :

  ruby ./main.rb

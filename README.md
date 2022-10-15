# TP 1 Conteneurisation

Ce TP a pour objectif de vous faire découvrir le fonctionnement des conteneurs Linux à travers Docker.

## Rendus du TP:

- Rendre un fichier contenant les réponses aux questions (format markdown)
- Pour chacune des questions, il faudra veiller à écrire les commandes utilisées permettant de répondre à la question. Ne pas hésiter à ajouter des détails supplémentaires afin de justifier votre réflexion.

## Contexte

Votre objectif sera d'automatiser l'environnement d'exécution d'une application en utilisant la conteneurisation.

## A) Installer Docker  

- Installer Docker en suivant la documentation officielle et s'assurer qu'il est fonctionnel :

```bash
docker run hello-world
```

## B) Déployer la base de données

1) Déployer une base données MongoDB (mode standalone) avec Docker. La base de données devra respecter les conditions suivantes:

- Une connection avec un user et un mot de passe sécurisé. 
- La base de données devra être accessible depuis l'host afin d'y accéder depuis un client MongoDB.


La base de données sera utilisé dans la prochaine section.

2) Télécharger MongoDB Compass (client graphique pour visualiser la base de données) et se connecter à MongoDB.
 
## C) Déploiement de l'API

Le dossier `api` contient le code d'une API REST NodeJS écrite en Typescript.

Une API (application programming interface ou « interface de programmation d’application ») est une interface logicielle qui permet de « connecter » un logiciel ou un service à un autre logiciel ou service afin d’échanger des données et des fonctionnalités.

REST (representational state transfer) est un style d'architecture logicielle définissant un ensemble de contraintes à utiliser pour créer des services web.

La communication avec l'API se fait au travers du protocole HTTP. HTTP définit un ensemble de méthodes de requête qui indiquent l'action que l'on souhaite réaliser sur la ressource indiquée.

Cette API très simple peut recevoir 2 types de requête :

- Une requête `POST`  qui permet de créer un nouvel utilisateur. Un utilisateur est décrit par les caractéristiques suivantes:
   - Un firstName
   - Un lastName
   - Un age
   - Un email
- Une requête `GET` qui permet de lister tous des utilisateurs.

Cette API communique avec une base de données MongoDB afin de stocker les utilisateurs créés et de lister ceux existant.

Il faudra réutiliser le conteneur MongoDB précédemment déployé et connecter l'API à cette base de données.

Vous pouvez démarrer le base de données MongoDB avec la commande `docker compose up`et la stopper avec `docker compose down`.

**ATTENTION** : L'API ne démarrera pas si elle n'est pas connectée à un MongoDB.

### Setup de l'API

#### Installation de Node et Yarn:

Afin de démarrer l'API il est nécessaire d'installer `node` dans votre environnement. Le plus simple est de passer par `nvm`.

`Node` est un runtime javascript permettant d'interpréter le language. `Nvm` (Node Version Manager) est un outil permettant d'installer différentes versions de NodeJS.

Ces 2 commandes vont respectivement installer `nvm` ainsi que la dernier version de `node` :

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
nvm use node
```

Vérifier que `node` est fonctionnel avec cette commande :

```bash
node -v
```

Une application NodeJS est composée de packages permettant d'apporter des fonctionnalités supplémentaires. Un package, est un ensemble de fonctionnalités développées et maintenues par la communauté NodeJS. Un package permet donc d'étendre les fonctionnalités d'une application, sans avoir à les coder directement soi-même. 

Yarn est un package manager permettant de gérer les packages nodejs. Il est nécessaire pour télécharger les dépendances de l'API:
```bash
npm install --global yarn
```

#### Architecture de l'application:

Le dossier `api` contient le code source de l'API. Celui-ci est composé de plusieurs dossiers et fichiers:

- `src` : contient le code source de l'application.
- `test`: contient la définition des tests de l'application.
- `package.json` : Fichier de configuration de l'application NodeJS. Il contient des métadonnées comme le nom de l'app, ses dépendances etc... Plus d'information sur la documentation [officielle](https://docs.npmjs.com/cli/v8/configuring-npm/package-json).
- Les autres fichiers sont essentiellement des fichiers de configuration dont vous n'avez pas besoin de vous préoccuper.

#### Démarrage de l'API

Une fois node et Yarn installés, il est nécessaire de télécharger les dépendances de l'API (il faut se situer dans le dossier de `api`):
```bash
cd api
yarn install
```

## On observe bien le dossier node_modules créé dans le dossier API

Cette commande va télécharger l'ensemble des packages nécessaires au bon fonctionnement de l'application dans le dossier `node_modules`.

Les packages nécessaires au fonctionnement de l'application sont définis dans la section `dependencies` du fichier `package.json` dans le dossier `api`.

Le code de l'application est écrit en Typescript. Il faut pour cela transpiler le code TS en JS grâce à cette commande:

```bash
yarn build
```
Cela va générer un dossier `dist` contenant le code Javascript.

## On a créé le dossier dist, on retrouve bien les fichiers créés en js

L'api peut ensuite être démarré grâce à la commande suivante:
```bash
node dist/main.js
```

#### Connexion de l'API à MongoDB

Il est nécessaire de configurer la connection à la base de données afin que l'API puisse démarrer.


La connection à MongoDB est faite dans le fichier `src/app.module.ts` `L8`. L'instruction `process.env.MONGODB_URI` permet de récupérer la valeur de la variable d'environnement `MONGODB_URI`. 

**Il est donc nécessaire de configurer cette variable d'environnement avant de démarrer l'API** 

- Chercher sur internet la commande permettant de configurer une variable d'environnement sous Linux.


#### Tester l'API

Une fois démarrée, l'API est accessible à l'adresse suivante : http://localhost:3000.

L'API expose 2 routes:
- GET /users/ --> Liste tous les objets "Users" dans MongoDB
- POST /users/ --> Créer un objet user et le persiste dans MongoDB

La commande `curl` permet de communiquer avec l'API au travers du protocole HTTP. Les commandes `curl` suivantes permettent respectivement de : 
- Créer un nouvel utilisateur.
- Lister les utilisateurs existants.

Les données sont renvoyées au format `JSON`.

```bash
# Créer un user
curl --location --request POST 'http://localhost:3000/users' \
--header 'Content-Type: application/json' \
--data-raw '{"email":"alexis.bel@ynov.com", "firstName": "Alexis", "lastName": "Bel"}'

# Liste tous les users
curl 'http://localhost:3000/users' 
```


La 2ème commande doit renvoyer le user précédemment créé.

### 1) Conteneurisation de l'API

Dans cette partie vous allez conteneuriser l'API précédemment utilisée. Cela vous permettra de packager l'application dans une image Docker, qui pourra alors être déployé de manière totalement indépendante. Cette image sera par ailleurs utilisé dans les prochains TP lors que vous effectuerez son déploiement en production.

**Pour toutes les prochaines questions, vous pouvez vous inspirer de la [section Get started](https://docs.docker.com/get-started/) sur le site Docker**

#### a) Création de l'image à partir d'un Dockerfile

La première étape consiste à créer l'image à partir d'un Dockerfile.

Appuyez vous sur la [documentation de Docker concernant la syntaxe du Dockerfile](https://docs.docker.com/engine/reference/builder/).

Voici un exemple de Dockerfile pour une application Python (un autre langage de programmation):

```Dockefile
FROM ubuntu:18.04
COPY . /app
RUN make /app
CMD python /app/app.py
```

Chaque instruction créer une nouvelle couche:
- `FROM` Créer une première couche à partir de l'image `ubuntu:18.04`
- `COPY` Copier les fichier du répertoire courant (celui dans lequel se situe le Dockerfile) dans le dossier spécifier (ici `/app`) à l’intérieur de l'image.
- `RUN` Execute la commande `make` qui permet de builder l'application.
- `CMD` Spécifie la commande à lancer à chaque fois que le conteneur sera créé à partir de l'image.

Inspirez vous de ce Dockerfile pour créer le Dockerfile de notre API NodeJS. Il faudra réutiliser les commandes précédemment utiliser dans le Dockerfile afin de réaliser les étapes nécessaire. Pour rappel, voici les étapes:

- Installation du runtime NodeJS
- Installation de `yarn``
- Installation des dépendances avec `yarn install`
- Le build de l'application avec `yarn build`
- Le démarrage de l'application avec `node dist/main.js`

Une fois le Dockerfile finalisé, créer l'image avec la commande `docker build -t <VOTRE_NOM>/myapi:dev .` à exécuter dans le même répertoire que le Dockerfile.

S'il n'y a pas d'erreur lors du build de votre image, celle-ci devrait être lisible en lançant la commande `docker image ls`.

#### b) Créer le conteneur à partir de l'image.

La commande `docker run <NOM_DE_VOTRE_IMAGE>` permet de créer un conteneur à partir de l'image de votre API.

Exécuter cette commande. Vous allez recevoir un message d'erreur lorsque le conteneur va essayer de démarrer. Comment expliquez cette erreur ? (N'oubliez pas que l'API a besoin de MongoDB pour fonctionner)

Regarder la [documentation de docker run](https://docs.docker.com/engine/reference/commandline/run/) afin de trouver un moyen de corriger ce problème.

#### c) Docker compose 

Mettez à jour la configuration du fichier `docker-compose.yaml` afin déployer le conteneur précédemment créer avec `docker run` en utilisant la commande `docker compose up`



#### d) Optimiser l'image précédemment créée.

L'image précédemment créée est fonctionnelle, mais peut êre optimiser sur plusieurs aspects: 

- La taille de l'image doit être la plus petit possible. Tips : Penser aux image de base `alpine` qui sont plus légère.
- Ne mettre dans l'image que le strict nécessaire pour faire fonctionner l'application. Seule les dossier `dist`et `node_modules` sont nécessaire pour démarrer l'application.
- Réduire au maximum les privilèges de l'utilisateur configurer dans l'image (pas de root). Pour cela vous pouvez utiliser [la directive `USER`](https://docs.docker.com/engine/reference/builder/#user)

#### d) Partager l'image sur le Dockerhub

Créer vous un compte sur le DockerHub et partagez l'image que vous avez créé. 
Vous pouvez vous référer à [cette documentation de Docker](https://docs.docker.com/get-started/04_sharing_app/)


## D) Persistance des données

### 1) Supprimer le conteneur MongoDB et le récréer. Qu'est il arrivé aux données et pourquoi ?

### 2) Mettre en place un mécanisme permettant de persister les données même quand le conteneur est supprimé (pensez aux volumes).

## E) (Bonus) Réplication de l'API et load balancing avec un proxy NGINX

- Créer plusieurs replica de l'API 
- Créer un conteneur NGINX en front gérant les requêtes vers l'API et permettant de load balancer les requêtes vers les différents replica de l'API, le tout à partir d'un même hostname.
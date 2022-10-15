# TP 1 Conteneurisation

Ce Docuent a pour objectif de répondre aux différents point du fichier ``` README.md ```

## A) Installer Docker  

Afin d'installer docker, on a tout d'abord installer WSL2, afin de pouvoir accéder à une machine virtuelle UBUNTU. Puis on a installer Docker Desktop directement avec le logiciel d'installation. 

## B) Déployer la base de données

### 1) Commande pour déployer la base de donnée mongo avec docker :

```bash
docker run --name docker-TP1 -d mongo:latest
```

On a ensuite créer un fichier docker-compose.yaml, en ajoutant les informations spécifiant la connection à la base de donnée mongoDB :

```yaml
# Use root/example as user/password credentials
version: '3.1'

services:
  mongo:
    image: mongo
    restart: always
    ports:
      - 27017:27017
    environment:
      MONGO_INITDB_ROOT_USERNAME: ${MONGODB_USERNAME}
      MONGO_INITDB_ROOT_PASSWORD: ${MONGODB_PASSWORD}
```

Les lignes liées aux variables d'environnement font ici référence au fichier ``` .env```, où l'on retrouve la valeur de l'```USERNAME``` ainsi que du ```PASSWORD``` :

```bash 
MONGODB_USERNAME="root"
MONGODB_PASSWORD="toto"
```
On a ensuite lancé la commande suivante, qui précise l'emplacement du fichier ```.yaml``` :

```bash 
docker-compose -f docker-compose.yaml up
```

Cependant, nous pouvons également lancé la commande : 

```bash
docker compose up
```
Cette dernière va automatiquement détectée l'emplacement d'un fichier de configuration ```.yaml``` et déployer une base de donnée avec ces données de configuration.

### 2) Installation et mise en route de MongoDB Compass

Afin de faire fonctionner mongoDB Compass et de se connecter à la base de donnée, nous avons entrés l'```USERNAME``` ainsi que le ``` PASSWORD ```. Nous précisons également le port de connexion : ```27017 ```. Ce dernier est présent dans la doc et nous pécise le port à utiliser. Nous obtenons donc le lien de connexion suivant :

```bash
mongodb://root:toto@localhost:27017
```

## C) Déploiement de l'API

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
#### Démarrage de l'API

Une fois node et Yarn installés, il est nécessaire de télécharger les dépendances de l'API (il faut se situer dans le dossier de `api`):
```bash
cd api
yarn install
```

L'installation des packages crée dans notre projet un dossier ```node_modules```.

Le code de l'application est écrit en Typescript. Il faut pour cela transpiler le code TS en JS grâce à cette commande:

```bash
yarn build
```
Cela va générer un dossier `dist` contenant le code Javascript.

On démarre ensuite l'api grâce à la commande suivante:
```bash
node dist/main.js
```

#### Connexion de l'API à MongoDB

Il est nécessaire de configurer la connection à la base de données afin que l'API puisse démarrer.

La connection à MongoDB est faite dans le fichier `src/app.module.ts` `L8`. L'instruction `process.env.MONGODB_URI` permet de récupérer la valeur de la variable d'environnement `MONGODB_URI`. 

Nous avons entré la variable d'environnement ```MONGODB_URI``` dans un terminal avec la commande ```export```. Nous lui attribuons le lien que nous avions obtenu dans la partie B)-2) :
```bash
export MONGODB_URI="mongodb://root:toto@localhost:27017"
```

Nous avons ensuite utilisé la commande ```echo``` afin de vérifier que la variable d'environnement fonctionnait :
```bash
echo MONGODB_URI
```

On a enfin lancé la commande :

```bash
node dist/main.js
```

On a pu ensuite accéder à l'URL ```localhost:3000``` pour tomber sur du texte "Hello World", puis avec l'URL ```localhost:3000/users/``` on a pu afficher un tableau vide des users. Car n'en contenant aucun pour l'instant.

Afin de tester l'API, nous avons entré les commandes suivantes, pour dans un premier temps créé un utilisateur, puis afin de voir les utilisateurs :

```bash
# Créer un user
curl --location --request POST 'http://localhost:3000/users' \
--header 'Content-Type: application/json' \
--data-raw '{"email":"alexis.bel@ynov.com", "firstName": "Alexis", "lastName": "Bel"}'

# Liste tous les users
curl 'http://localhost:3000/users' 
```
### 1) Conteneurisation de l'API

Dans cette partie vous allez conteneuriser l'API précédemment utilisée. Cela vous permettra de packager l'application dans une image Docker, qui pourra alors être déployé de manière totalement indépendante. Cette image sera par ailleurs utilisé dans les prochains TP lorsque nous effectuerons son déploiement en production.

**Afin de nous aider, nous sommes allés voir sur la [section Get started](https://docs.docker.com/get-started/) sur le site Docker**

#### a) Création de l'image à partir d'un Dockerfile

La première étape consiste à créer l'image à partir d'un Dockerfile.

Nous nous sommes appuyés sur la [documentation de Docker concernant la syntaxe du Dockerfile](https://docs.docker.com/engine/reference/builder/), comme expliqué dans le fichier ```README.md```.

Nous avons donc créé un fichier ```Dockerfile``` dans le dossier api. Dans celui-ci, nous avons entré plusieurs lignes qui ont pour objectif de faire fonctionner notre API ur une autre machine :

```Dockerfile
# syntax=docker/dockerfile:1
FROM node
COPY . . 
RUN yarn install
RUN yarn build
CMD node dist/main.js
```

Une fois le ```Dockerfile``` finalisé, nous avons créé l'image avec la commande `docker build jeremy/myapi:dev .` que nous executons dans le même répertoire que le Dockerfile (api).

Grâce à la commande `docker image ls`, nous pouvons voir toutes les images que nous avons créés. Nous pouvons donc observer la nouvelle image que nous venons de créé, `jeremy/myapi`, avec le tag `dev`

#### b) Créer le conteneur à partir de l'image.

Lorsque nous lançons la commande `docker run jeremy/myapi:dev`, nous obtenons une erreur. En effet, la connexion ne se fait pas avec la base de donnée. Afin de régler ce problème, nous avons dû ajouté plusieurs lignes au ficher `docker-compose.yaml` :

```yaml
# Use root/example as user/password credentials
version: '3.1'

services:
  mongo:
    image: mongo
    restart: always
    ports:
      - 27017:27017
    environment:
      MONGO_INITDB_ROOT_USERNAME: ${MONGODB_USERNAME}
      MONGO_INITDB_ROOT_PASSWORD: ${MONGODB_PASSWORD}
  api: 
    image: jeremy/myapi:dev
    restart: always
    ports:
      - 3000:3000
    environment:
      MONGODB_URI: mongodb://${MONGODB_USERNAME}:${MONGODB_PASSWORD}@mongo:27017
```

Avec ces nouvelles lignes, nous précisons à l'api le lien de connexion à la base de données. Nous pouvons voir que nous ne commençons pas le lien par `localhost` mais bien par `mongodb`, car l'image que nous avions créé est une image `mongo`.

Afin de déployer le conteneur précédemment créé avec `docker run jeremy/myapi:dev`, nous lançons la commande `docker compose up`.

#### d) Optimiser l'image précédemment créée.

- Afin de réduire la taille de l'image, nous avons utilisé une base `alpine`, qui est plus légère.
- Les dossiers node_modules, dist et le ficher Dockerfile sont inutiles pour l'utilisateur et ne prenne que de la place en plus. Afin de corriger ce problème, nous avons créé un fichier `.dockerignore` où nous avons entré les fichiers et dossiers que la commande `docker compose up` doit ignorer.

Notre fichier `Dockerfile` modifié :

```Dockerfile
# syntax=docker/dockerfile:1
FROM node:alpine
COPY . . 
RUN yarn install
RUN yarn build
CMD node dist/main.js
```

Notre fichier `.dockerignore` :

```.dockerignore
node_modules
dist
Dockerfile
```
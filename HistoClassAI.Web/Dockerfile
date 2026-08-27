# Étape 1 : Construction de l'application (Build)
FROM node:22-alpine AS build-stage

WORKDIR /app

# Copier les fichiers de package
COPY package*.json ./

# Installer les dépendances
RUN npm install

# Copier le reste du code
COPY . .

# Construire l'application pour la production
RUN npm run build

# Étape 2 : Serveur web (Nginx)
FROM nginx:alpine AS production-stage

# Copier la configuration personnalisée pour supporter le Vue Router
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copier les fichiers statiques construits
COPY --from=build-stage /app/dist /usr/share/nginx/html

# Exposer le port 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

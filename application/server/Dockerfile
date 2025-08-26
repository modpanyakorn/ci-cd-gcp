FROM node:24.5.0-alpine3.22 AS build

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .

FROM node:24.5.0-alpine3.22

WORKDIR /app
RUN npm install -g pm2
COPY --from=build /app /app

EXPOSE 3001
CMD ["pm2-runtime", "start", "index.js", "--name", "chat-backend-api"]

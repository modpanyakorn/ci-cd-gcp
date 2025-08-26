FROM node:24.5.0-alpine3.22 AS build
WORKDIR /app

COPY package*.json ./
RUN npm ci
COPY . .

ARG REACT_APP_LOCALHOST_KEY=chat-app-current-user
ENV REACT_APP_LOCALHOST_KEY=$REACT_APP_LOCALHOST_KEY
RUN npm run build

FROM nginx:stable

COPY ./nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 3000
CMD ["nginx","-g","daemon off;"]

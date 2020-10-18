FROM node:lts-alpine

RUN npm install -g http-server

WORKDIR /app

COPY src/package*.json ./

RUN npm install

COPY src .

RUN npm run build

EXPOSE 8080

CMD [ "http-server", "dist" ]

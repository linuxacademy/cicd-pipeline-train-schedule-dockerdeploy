FROM node:carbon
WORKDIR /usr/src/app
COPY package*.json ./
RUN curl github.com
COPY . .
EXPOSE 8080
//CMD [ "npm", "start" ]

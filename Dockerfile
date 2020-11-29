FROM node:carbon
WORKDIR /usr/src/app
COPY package*.json ./
COPY . .
EXPOSE 8080
RUN echo 'success'

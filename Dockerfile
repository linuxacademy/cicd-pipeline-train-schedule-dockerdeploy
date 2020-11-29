FROM node:carbon
WORKDIR /usr/src/app
COPY package*.json ./
RUN install curl
COPY . .
EXPOSE 8080
RUN echo 'success'

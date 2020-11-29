FROM node:carbon
WORKDIR /usr/src/app
COPY package*.json ./
COPY . .
EXPOSE 9090
RUN echo 'success'

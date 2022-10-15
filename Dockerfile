# syntax=docker/dockerfile:1
FROM node:alpine
COPY . . 
RUN yarn install
RUN yarn build
CMD node dist/main.js
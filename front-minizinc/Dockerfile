FROM node:13

WORKDIR /code

ENV PATH ./node_modules/.bin:$PATH

COPY package*.json ./

RUN npm install --silent
RUN npm install react-scripts@3.4.1 -g --silent

COPY . .

CMD ["npm" , "start"]


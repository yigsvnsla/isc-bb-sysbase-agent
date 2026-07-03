FROM node:22-alpine

WORKDIR /app

COPY docusaurus/package.json docusaurus/package-lock.json* ./
RUN npm install

COPY docusaurus/ .
COPY docs ./docs

RUN npm run build

EXPOSE 3000

CMD ["npm", "run", "serve", "--", "--host", "0.0.0.0", "--port", "3000"]

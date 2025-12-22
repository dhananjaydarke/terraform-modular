FROM node:18-alpine

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm install --production

COPY . .

ENV PORT=8080

EXPOSE 8080

CMD ["npm", "start"]


docker build -t backend_repo_url:latest .
docker push backend_repo_url:latest.

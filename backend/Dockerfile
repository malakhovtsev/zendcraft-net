# Keep the Node major version in sync with /.nvmrc.
FROM node:24-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY tsconfig.json ./
COPY src ./src
RUN npm run build

FROM node:24-alpine
ENV NODE_ENV=production
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force
COPY --from=build /app/dist ./dist

# On Lambda, the adapter turns invocations into HTTP requests to the app.
# Anywhere else it's never started, so the image still runs as a plain server.
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:1.1.0 /lambda-adapter /opt/extensions/lambda-adapter
ENV AWS_LWA_PORT=3000

USER node
EXPOSE 3000

# Any real status response counts, so the game server being down doesn't
# mark the API unhealthy.
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1:3000/api/java-server-status | grep -q '"online":' || exit 1

CMD ["node", "dist/index.js"]

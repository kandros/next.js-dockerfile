FROM node:15.3.0-alpine3.10 as deps
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn --production --silent
RUN cp -R node_modules /tmp/prod_node_modules
RUN yarn 

FROM deps as builder
WORKDIR /app
COPY . .
ENV NODE_ENV=production
RUN yarn build


FROM node:15.3.0-alpine3.10 AS release
ENV NODE_ENV=production
WORKDIR /app
COPY --from=builder /app/next.config.js ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /tmp/prod_node_modules ./node_modules
# COPY --from=builder /app/.env.production ./.env.production
COPY --from=builder /app/package.json ./package.json
EXPOSE 3000
CMD ["npm", "start"]


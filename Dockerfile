FROM node:16 as build

# install dependencies
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn run ci

# Copy all local files into the image.
COPY . .

RUN yarn run build

###
# Only copy over the Node pieces we need
# ~> Saves 35MB
###
FROM node:16 as App

WORKDIR /app
COPY --from=build /app/build/. ./build
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json ./
COPY --from=build /app/yarn.lock ./
RUN mkdir -p ./src/css
COPY --from=build /app/src/css/custom.css ./src/css/custom.css
COPY --from=build /app/docusaurus.config.js ./


EXPOSE 8080
CMD ["yarn", "run", "serve"]